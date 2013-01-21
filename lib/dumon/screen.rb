module Dumon

  ###
  # This class represents an abstract pattern how concrete classes providing info
  # about outputs available on your system look like.
  class Screen

    ###
    # System tool to be used for outputs management.
    attr_accessor :stool

    ###
    # Asserts whether the sub-class can find a concrete system tool.
    def assert_stool
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Gets array of possible outputs.
    def outputs
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

  end

  class Xrandr < Screen

    def assert_stool #:nodoc:
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
