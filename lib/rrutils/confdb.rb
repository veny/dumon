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
          rslt = JSON.load(input_stream)
        rescue => e
          Dumon::logger.warn "failed to read configuration: #{e.message}"
        ensure
          input_stream.close unless input_stream === STDIN
        end
      end

      Dumon::logger.debug "Configuration keys: #{rslt.keys}"
      rslt
    end

    ###
    # Writes out the configuration to a given output stream.
    def write(conf, output_stream=STDOUT)
      begin
        output_stream.write(JSON.pretty_generate(conf))
      rescue => e
        Dumon::logger.error "failed to write configuration: #{e.message}"
      ensure
        output_stream.close unless output_stream === STDOUT
      end
    end

  end

end
