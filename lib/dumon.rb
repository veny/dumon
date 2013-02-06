#!/usr/bin/ruby

require 'logger'
require 'gtk2'
require 'dumon/version'


###
# This module represents the entry point of Dumon tool.
module Dumon

  autoload :XrandrManager,   'dumon/omanager'
  autoload :Tray,            'dumon/ui'

  class << self

    ###
    # Logger used for logging output.
    attr_accessor :logger

  end


  ###
  # Runs the application.
  def self.run
    if ARGV[0] == '--daemon'
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

    ui = Dumon::Tray.new
    ui.omanager = Dumon::XrandrManager.new
    ui.render

  end

end


# Configuration of logging.
Dumon::logger = Logger.new(STDOUT)
Dumon::logger.level = Logger::INFO

Dumon::logger.info \
    "Dumon #{Dumon::VERSION}, running on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"


# development
#Dumon::logger.level = Logger::DEBUG
#Dumon::run
