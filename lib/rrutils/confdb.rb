require 'json'

module Rrutils

  ###
  # This modul represents a mixin for configuration
  # that can be 'loaded from' or 'stored into' a persistent repository.
  module Confdb

    ###
    # Loads and returns a configuration from a file.
    def load(filename="#{Dir.home}#{File::SEPARATOR}.config#{File::SEPARATOR}dumon.conf")
      return {:mode=>:single, :out=>'VGA1', :resolution=>'1600x900'} # single
#      return {:mode=>:mirror, :resolution=>'1600x900'} # mirror
#      return {:mode=>:sequence, :outs=>['VGA1', 'LVDS1'], :resolutions=>{'1920x1080', '1600x900'}, :primary=>:none} # sequence
    end

    ###
    # Writes out the configuration to a given output stream.
    def write(conf, filename="#{Dir.home}#{File::SEPARATOR}.config#{File::SEPARATOR}dumon.conf")
      File.open(filename, 'w') do |f|
        f.write(JSON.pretty_generate(conf))
      end
    end

  end

end
