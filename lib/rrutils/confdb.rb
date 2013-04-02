require 'json'

module Rrutils

  ###
  # This modul represents a mixin for configuration
  # that can be 'loaded from' or 'stored into' a persistent repository.
  module Confdb

    ###
    # Loads and returns a configuration from a file.
    def read(input_stream=STDIN)
      rslt = {}
      unless input_stream.nil?
        begin
          rslt = JSON.load(input_stream) # returns 'nil' if empty file
          rslt ||= {}
          Dumon::logger.debug "Configuration readed, keys=#{rslt.keys}"
        rescue => e
          Dumon::logger.warn "failed to read configuration: #{e.message}"
        ensure
          input_stream.close unless input_stream === STDIN
        end
      end

      rslt
    end

    ###
    # Writes out the configuration to a given output stream.
    def write(conf, output_stream=STDOUT)
      raise ArgumentError, 'configuration not a hash' unless conf.is_a? Hash

      begin
        output_stream.write(JSON.pretty_generate(conf))
        Dumon::logger.debug "Configuration written, keys=#{conf.keys}"
      rescue => e
        Dumon::logger.error "failed to write configuration: #{e.message}"
      ensure
        output_stream.close unless output_stream === STDOUT
      end
    end

  end

end
