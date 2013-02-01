module Dumon

  ###
  # This class represents a base class defining how concrete sub-classes manage
  # output devices available on your system.
  class OutDeviceManager

    ###
    # System tool to be used for output devices management.
    attr_accessor :stool

    ###
    # Cached information about current output devices.
    # Format: {output_name=>{:default=>"AxB",:current=>"CxD",:resolutions=>[...], ...}
    # Sample: {
    #   "LVDS1"=>{:resolutions=>["1600x900", "1024x768"], :default=>"1600x900"},
    #   "VGA1" =>{:resolutions=>["1920x1080", "720x400"], :default=>"1920x1080", :current=>"1920x1080"}
    #         }
    attr_accessor :outputs

    ###
    # Reads info about current accessible output devices and their settings.
    def read
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Switch to given single output device with given resolution.
    def single(output, resolution, type=nil)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Mirrors output on all devices with given resolution.
    def mirror(resolution)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Distributes output to given devices with given order and resolution.
    # *param* outputs in form [["LVDS1", "1600x900"], [VGA1", "1920x1080"]]
    def sequence(outputs)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Gets default resolution of given output device.
    def default_resolution(output)
      raise 'no outputs' if self.outputs.nil? or self.outputs.empty?
      raise "unknown output: #{output}" unless self.outputs.keys.include?(output)
      raise "no default resolution, output: #{output}" unless self.outputs[output].keys.include?(:default)

      self.outputs[output][:default]
    end

    ###
    # Gets list of common resolutions of all output devices.
    def common_resolutions
      raise 'no outputs' if self.outputs.nil? or self.outputs.empty?

      rslt = []
      o1 = self.outputs.keys.first
      self.outputs[o1][:resolutions].each do |res|
        self.outputs.keys.each do |o|
          next if o === o1
          rslt << res if self.outputs[o][:resolutions].include?(res)
        end
      end

      rslt
    end

  end


  ###
  # This class manages output devices via *xrandr* system tool.
  class XrandrManager < OutDeviceManager

    ###
    # Constructor.
    # Checks whether the 'xrandr' system tool is there.
    def initialize
      paths = ['xrandr', '/usr/bin/xrandr']
      paths.each do |path|
        begin
          `#{path}`
          self.stool = path
          Dumon.logger.info "System tool found: #{path}"
          break
        rescue  => e
          Dumon.logger.warn "unknown tool: #{path}, message: #{e.message}"
        end
      end

      raise "no system tool found, checked for #{paths}" if self.stool.nil?

      self.read
    end

    def read #:nodoc:
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
      self.outputs = rslt
      rslt
    end

    def single(output, resolution, type=nil) #:nodoc:
      self.read if self.outputs.nil? or self.outputs.empty?
      raise "uknown output: #{output}" unless self.outputs.keys.include?(output)

      resolution = self.default_resolution(output) if resolution.nil?

      cmd = "#{self.stool} --output #{output} --mode #{resolution} --pos 0x0"
      self.outputs.keys.each do |o|
        cmd << " --output #{o} --off" unless o === output
      end

      Dumon::logger.debug "Command: #{cmd}"
      `#{cmd}`
    end

    def mirror(resolution) #:nodoc:
      self.read if self.outputs.nil? or self.outputs.empty?

      cmd = "#{self.stool}"
      self.outputs.keys.each { |o| cmd << " --output #{o} --mode #{resolution}" }

      Dumon::logger.debug "Command: #{cmd}"
      `#{cmd}`
    end

    def sequence(outputs) #:nodoc:
      raise 'not an array' unless outputs.kind_of?(Array)
      outputs.each { |pair| raise 'item not a pair' if !pair.kind_of?(Array) and pair.size != 2 }

      cmd = "#{self.stool}"
      for i in 0..outputs.size - 1
        output = outputs[i][0]
        resolution = outputs[i][1]
        resolution = self.default_resolution(output) if resolution.nil?
        cmd << " --output #{output} --mode #{resolution}"
        cmd << " --right-of #{outputs[i - 1][0]}" if i > 0
      end

      Dumon::logger.debug "Command: #{cmd}"
      `#{cmd}`
    end

  end

end