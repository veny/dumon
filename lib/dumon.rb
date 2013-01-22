#!/usr/bin/ruby

require 'logger'
require 'gtk2'
require 'dumon/version'


###
# This module represents the entry point of Dumon tool.
module Dumon

  autoload :Xrandr,          'dumon/screen'
  autoload :Tray,            'dumon/ui'

  class << self

    ###
    # Logger used for logging output.
    attr_accessor :logger

  end

end


# Configuration of logging.
Dumon::logger = Logger.new(STDOUT)
Dumon::logger.level = Logger::INFO
Dumon::logger.level = Logger::DEBUG

Dumon::logger.info \
    "Dumon #{Dumon::VERSION}, running on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"


# start the app
screen = Dumon::Xrandr.new

ui = Dumon::Tray.new
ui.screen = screen
ui.render
