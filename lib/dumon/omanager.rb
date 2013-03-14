module Dumon

  ###
  # This class represents a base class defining how concrete sub-classes manage
  # output devices available on your system.
  class OutDeviceManager
    include Rrutils::Options

    ###
    # System tool to be used for output devices management.
    attr_reader :stool

    ###
    # Cached information about current output devices.
    # Value will be updated by each invocation of #read.
    #
    # Format: {output_name=>{:default=>"AxB",:current=>"CxD",:resolutions=>[...], ...}
    # Sample: {
    #   "LVDS1"=>{:resolutions=>["1600x900", "1024x768"], :default=>"1600x900"},
    #   "VGA1" =>{:resolutions=>["1920x1080", "720x400"], :default=>"1920x1080", :current=>"1920x1080"}
    #         }
    attr_reader :outputs

    ###
    # Switches output according to given mode and corresponding parameters.
    #
    # Possible options:
    #
    # Single output:
    # {:mode=>:single, :out=>'VGA1', :resolution=>'1600x900'}
    # Mirrored outputs:
    # {:mode=>:mirror, :resolution=>'1600x900'}
    # Sequence of outputs:
    # {:mode=>:hsequence, :outs=>['VGA1', 'LVDS1'], :resolutions=>['1920x1080', '1600x900'], :primary=>:none}
    def switch(options)
      # pre-conditions
      verify_options(options, {
        :mode => [:single, :mirror, :hsequence, :vsequence],
        :out => :optional, :outs => :optional,
        :resolution => :optional, :resolutions => :optional,
        :primary => :optional
      })

      mode = options[:mode].to_sym

      case mode
      when :single
        verify_options(options, {:mode => [:single], :out => outputs.keys, :resolution => :optional})
        out_name = options[:out]
        # given resolution exists for given output
        unless options[:resolution].nil?
          assert(outputs[out_name][:resolutions].include?(options[:resolution]),
              "unknown resolution: #{options[:resolution]}, output: #{out_name}")
        end
        single(out_name, options[:resolution])
      when :mirror
        verify_options(options, {:mode => [:mirror], :resolution => :mandatory})
        # given resolution exist for all outputs
        outputs.each do |k,v|
          assert(v[:resolutions].include?(options[:resolution]), "unknown resolution: #{options[:resolution]}, output: #{k}")
        end
        mirror(options[:resolution])
      when :hsequence, :vsequence
        verify_options(options, {:mode => [:hsequence, :vsequence], :outs => :mandatory, :resolutions => :mandatory, :primary => :optional})
        assert(options[:outs].is_a?(Array), 'parameter :outs has to be Array')
        assert(options[:resolutions].is_a?(Array), 'parameter :resolutions has to be Array')
        assert(options[:outs].size == options[:resolutions].size, 'size of :outs and :resolutions does not match')
        assert(options[:outs].size > 1, 'sequence mode expects at least 2 outputs')
        assert(outputs.keys.include?(options[:primary]), "unknown primary output: #{options[:primary]}") unless options[:primary].nil?
        sequence(options[:outs], options[:resolutions], options[:primary], :hsequence === options[:mode])
      end

      Dumon::App.instance.current_profile = options
    end

    ###
    # Reads info about current accessible output devices and their settings.
    # Readed infos will be stored and accessible via reader 'outputs'.
    def read
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Gets default resolution of given output device.
    def default_resolution(output)
      assert(!outputs.nil?, 'no outputs found')
      assert(outputs.keys.include?(output), "unknown output: #{output}")
      assert(outputs[output].keys.include?(:default), "no default resolution, output: #{output}")

      outputs[output][:default]
    end

    ###
    # Gets list of common resolutions of all output devices.
    def common_resolutions
      assert(!outputs.nil?, 'no outputs found')

      rslt = []
      o1 = outputs.keys.first
      outputs[o1][:resolutions].each do |res|
        outputs.keys.each do |o|
          next if o === o1
          rslt << res if outputs[o][:resolutions].include?(res)
        end
      end

      rslt
    end


    protected


    ###
    # Switch to given single output device with given resolution.
    # *param* output
    # *resolution* nil for default resolution
    def single(output, resolution=nil)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Mirrors output on all devices with given resolution.
    def mirror(resolution)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Distributes output to given devices with given order and resolution.
    # *param* outs in form ['VGA1', 'LVDS1']
    # *resolutions* in form ['1920x1080', '1600x900']
    # *param* primary name of primary output
    # *param* horizontal whether horizontal linie of outputs
    def sequence(outs, resolutions, primary=:none, horizontal=true)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

  end


  ###
  # This class manages output devices via *xrandr* system tool.
  class XrandrManager < OutDeviceManager

    ###
    # Constructor.
    # Checks whether the 'xrandr' system tool is there.
    def initialize
      paths = ['/usr/bin/xrandr', 'xrandr']
      paths.each do |path|
        begin
          `#{path}`
          @stool = path
          Dumon.logger.info "System tool found: #{path}"
          break
        rescue  => e
          Dumon.logger.warn "unknown tool: #{path}, message: #{e.message}"
        end
      end

      raise "no system tool found, checked for #{paths}" if self.stool.nil?

      # just to check if it works
      self.read
    end

    def read #:nodoc:
      @outputs = nil # clear previous info
      rslt = {}

      output = nil
      xrandr_out = `#{self.stool} -q`
      xrandr_out.each_line do |line|
        if line =~ /^\w+ connected /
          output = line[/^\w+/]
          rslt[output] = {:resolutions => []}
        end
        if line =~ /^\s+[0-9x]+\s+\d+/ and not output.nil?
          resolution = line[/[0-9x]+/]
          rslt[output][:default] = resolution if line.include? '+'
          rslt[output][:current] = resolution if line.include? '*'
          rslt[output][:resolutions] << resolution
        end
      end
      Dumon::logger.debug "Outputs found: #{rslt}"

      # verify structure of readed infos
      assert(!rslt.empty?, 'no outputs found')
      rslt.keys.each do |k|
        out_meta = rslt[k]
        verify_options(out_meta, {:resolutions=>:mandatory, :default=>:mandatory, :current=>:optional})
        assert(out_meta[:resolutions].size > 1, "no resolution found, output=#{k}")
      end

      @outputs = rslt
      rslt
    end


    protected


    def single(output, resolution=nil) #:nodoc:
      assert(!outputs.nil?, 'no outputs found')
      assert(outputs.keys.include?(output), "unknown output: #{output}")

      resolution = self.default_resolution(output) if resolution.nil?

      cmd = "#{self.stool} --output #{output} --mode #{resolution} --pos 0x0"
      self.outputs.keys.each do |o|
        cmd << " --output #{o} --off" unless o === output
      end

      Dumon::logger.debug "Command: #{cmd}"
      `#{cmd}`
    end

    def mirror(resolution) #:nodoc:
      assert(!outputs.nil?, 'no outputs found')

      cmd = "#{self.stool}"
      self.outputs.keys.each { |o| cmd << " --output #{o} --mode #{resolution}" }

      Dumon::logger.debug "Command: #{cmd}"
      `#{cmd}`
    end

    def sequence(outs, resolutions, primary=:none, horizontal=true) #:nodoc:
      cmd = "#{self.stool}"
      for i in 0..outs.size - 1
        output = outs[i]
        resolution = resolutions[i]
        resolution = self.default_resolution(output) if resolution.nil?
        cmd << " --output #{output} --mode #{resolution}"
        cmd << ' --primary' if primary.to_s == output
        if horizontal
          cmd << " --right-of #{outs[i - 1]}" if i > 0
        else
          cmd << " --below #{outs[i - 1]}" if i > 0
        end
      end

      Dumon::logger.debug "Command: #{cmd}"
      `#{cmd}`
    end

  end

end
