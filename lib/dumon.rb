#!/usr/bin/ruby

require 'singleton'
require 'logger'
require 'gtk2'
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

    ###
    # User interface of Dumon tool.
    attr_reader :ui

    ###
    # Primary output.
    attr_accessor :primary_output

    ###
    # Constructor.
    def initialize
      @ui = new_ui
      Dumon::logger.debug "Used UI: #{ui.class.name}"

      # storage of preferred resolution for next rendering (will be cleared by output changing)
      # {"LVDS1" => "1600x900", "VGA1" => "800x600"}
      @selected_resolution = {}

      # initial primary output
      self.primary_output = :none
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

#      write
      ui.render
    end

  end # App

end


# Default configuration of logging.
Dumon::logger = Logger.new(STDOUT)
Dumon::logger.level = Logger::INFO

Dumon::logger.info \
    "Dumon #{Dumon::VERSION}, running on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"


# development mode
if __FILE__ == $0
  Dumon::logger.level = Logger::DEBUG
  Dumon::App.instance.run(ARGV[0] == '--daemon')
end
