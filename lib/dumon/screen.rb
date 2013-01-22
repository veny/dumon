module Dumon

  ###
  # This class represents an abstract pattern how concrete classes providing info
  # about outputs available on your system look like.
  class Screen

    ###
    # System tool to be used for outputs management.
    attr_accessor :stool

    ###
    # Reads info about current accessible outputs and their settings.
    def read
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Switch monitor to given output with given resolution.
    def switch(output, resolution, type=nil)
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

  end

  class Xrandr < Screen

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
    end

    def read #:nodoc:
      rslt = {}
      output = nil
      xrandr_out = `#{self.stool}`
      xrandr_out.each_line do |line|
        if line =~ /^\w+ connected /
          output = line[/^\w+/]
          rslt[output] = []
        end
        if line =~ /^\s+[0-9x]+\s+\d+/ and not output.nil?
          resolution = line[/[0-9x]+/]
          resolution << '*' if line.include? '+'
          rslt[output] << resolution
        end
      end

      rslt
    end

    def switch(output, resolution, type=nil) #:nodoc:
      outputs = self.read
      raise "uknown output: #{output}" unless outputs.keys.include?(output)

      cmd = "xrandr --output #{output}  --mode #{resolution} --pos 0x0"
      outputs.keys.each do |o|
        cmd << " --output #{o} --off" unless o === output
      end

      `#{cmd}`
    end

  end

end
