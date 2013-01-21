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


  ###
  # Basic error that indicates an unexpected situation during the client call.
#  class OrientdbError < StandardError
#    include ChainedError
#  end

  ###
  # Error indicating that access to the resource requires user authentication.
#  class UnauthorizedError < OrientdbError; end

end


# Configuration of logging.
Dumon::logger = Logger.new(STDOUT)
Dumon::logger.level = Logger::INFO

Dumon::logger.info \
    "Dumon #{Dumon::VERSION}, running on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"


#Dumon::logger.level = Logger::DEBUG
screen = Dumon::Xrandr.new
screen.assert_stool
Dumon::logger.info "Outputs found: #{screen.outputs}"

Gtk.init
ui = Dumon::Tray.new
ui.screen = screen
Gtk.main
