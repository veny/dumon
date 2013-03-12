#!/usr/bin/ruby

require 'singleton'
require 'logger'
require 'gtk2'
require 'fileutils'
require 'rrutils'
require 'dumon/version'
require 'dumon/omanager'
require 'dumon/ui'


###
# This module represents namespace of Dumon tool.
module Dumon

  class << self

    ###
    # Logger used for logging output.
    attr_accessor :logger

  end


  ###
  # This class represents an entry point
  class App
    include ::Singleton
    include Rrutils::Confdb
    include Rrutils::Options

    ###
    # User interface of Dumon tool.
    attr_reader :ui

    ###
    # Currently used profile.
    attr_accessor :current_profile

    ###
    # Constructor.
    def initialize
      @ui = new_ui
      Dumon::logger.debug "Used UI: #{ui.class.name}"

      # storage of preferred resolution for next rendering (will be cleared by output changing)
      # {"LVDS1" => "1600x900", "VGA1" => "800x600"}
      @selected_resolution = {}
    end

    ###
    # Factory method to create a new object of UI.<p/>
    # Can be used as Dependency Injection (DI) entry point:
    # you can reopen Dumon:App and redefine 'new_ui' if you implement a new UI class.
    # <pre>
    # class Dumon::App
    #   def new_ui; Dumon::XyUi.new; end
    # end
    # </pre>
    def new_ui(with=Dumon::GtkTrayUi)
      with.new
    end

    ###
    # Gets default config file.
    def config_file(mode='r')
      filename = "#{Dir.home}#{File::SEPARATOR}.config#{File::SEPARATOR}dumon.conf"

      # check and create directory structure
      dirname = File.dirname filename
      ::FileUtils.mkdir_p(dirname) unless Dir.exist?(dirname)

      # create file if does not exist
      File.open(filename, 'w').close unless File.exist? filename

      File.open(filename, mode)
    end

    ###
    # Reads Dumon's configuration.
    def read_config
      conf = read config_file
      conf = keys_to_sym conf

      # there can be a hook if config version is old

      conf
    end

    ###
    # Writes Dumon's configuration.
    def write_config(conf)
      conf[:version] = VERSION
      write(conf, config_file)
    end

    ###
    # Runs the application.
    def run(daemon=false)
      if daemon
        if RUBY_VERSION < '1.9'
          Dumon::logger.warn 'Daemon mode supported only in Ruby >= 1.9'
        else
          # Daemonize the process
          # - stay in the current directory
          # - don't redirect standard input, standard output and standard error to /dev/null
          Dumon::logger.info 'Running as daemon...'
          Process.daemon(true, true)
        end
      end

      #read(config_file)
      ui.render
    end

    ###
    # Quits cleanly the application.
    def quit
      ui.quit
      Dumon::logger.info 'Terminted...'
    end

  end # App

end


# Default configuration of logging.
Dumon::logger = Logger.new(STDOUT)
Dumon::logger.level = Logger::INFO

Dumon::logger.info \
    "Dumon #{Dumon::VERSION}, running on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"

# Capturing Ctrl+C to cleanly quit
trap('INT') do
  Dumon::logger.debug 'Ctrl+C captured'
  Dumon::App.instance.quit
end

# development mode
if __FILE__ == $0
  Dumon::logger.level = Logger::DEBUG
  Dumon::App.instance.run(ARGV[0] == '--daemon')
end
