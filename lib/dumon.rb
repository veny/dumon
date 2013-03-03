#!/usr/bin/ruby

require 'singleton'
require 'logger'
require 'gtk2'
require 'dumon/version'


###
# This module represents namespace of Dumon tool.
module Dumon

  autoload :Confdb,         'confdb.rb'
  autoload :XrandrManager,  'dumon/omanager'
  autoload :Tray,           'dumon/ui'

  class << self

    ###
    # Logger used for logging output.
    attr_accessor :logger

    ###
    #
#    attr_accessor :conf

  end


  ###
  # This class represents an entry point
  class App
    include ::Singleton
    include Confdb

    ###
    # User interface of Dumon tool.
    attr_reader :ui

    ###
    # Constructor.
    def initialize(options={})
      ui_type = options[:ui] || Dumon::Tray # IoC
      @ui = ui_type.new
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

      write
      ui.render
    end

  end # App

end


if __FILE__ == $0

  # Configuration of logging.
  Dumon::logger = Logger.new(STDOUT)
  Dumon::logger.level = Logger::INFO

  Dumon::logger.info \
      "Dumon #{Dumon::VERSION}, running on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
end


# development
Dumon::logger.level = Logger::DEBUG
Dumon::App.instance.run(ARGV[0] == '--daemon')
