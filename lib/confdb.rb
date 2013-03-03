require 'json'

###
# This modul represents a mixin for configuration
# that can be 'loaded from' or 'stored into' a persistent repository.
module Confdb

  ###
  # Loads and returns a configuration from a file.
  def load!(filename="#{Dir.home}#{File::SEPARATOR}.config#{File::SEPARATOR}dumon.conf")
    return {:a=>1, :b=>2}
  end

  ###
  # Writes out the configuration to a given output stream.
  def write(filename="#{Dir.home}#{File::SEPARATOR}.config#{File::SEPARATOR}dumon.conf")
    File.open(filename, 'w') do |f|
      f.write(JSON.pretty_generate({:a=>11, :b=>22}))
    end
  end

end
