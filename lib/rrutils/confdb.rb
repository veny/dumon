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
          input_stream.close
        end
      end

      Dumon::logger.debug "Profiles: #{rslt.keys}"
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
        output_stream.close
      end
    end

  end

end
