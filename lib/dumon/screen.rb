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
    # Gets array of possible outputs.
    def outputs
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

    def outputs #:nodoc:
      rslt = []
      out = `#{self.stool}`
      out.each_line do |line|
        rslt << line[/^\w+/] if line =~ /^\w+ connected /
      end
      rslt
    end

  end

end
