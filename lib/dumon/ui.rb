module Dumon

  ###
  # This class represents Dumon's user interface.
  class Ui

    attr_accessor :screen

    ###
    # Renders the UI.
    # Abstract method to be overridden by concrete sub-class.
    def render
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Quits the application.
    def quit
      Dumon::logger.info "Terminted..."
    end

  end


  ###
  # This class represents Dumon's user interface based on Gtk library.
  class GtkUi < Ui

    ###
    # Constructor.
    # Initializes the Gtk stuff.
    def initialize
      super
      Gtk.init
    end

    def render #:nodoc:
      Gtk.main
    end

    def quit #:nodoc:
      super
      Gtk.main_quit
    end

  end


  ###
  # This class represents a user interface represented by system tray icon and its context menu.
  # about outputs available on your system look like.
  class Tray < GtkUi

    def initialize
      super

      @tray = Gtk::StatusIcon.new
      @tray.stock = Gtk::Stock::ZOOM_100
      @tray.visible = true
      @tray.tooltip = "Dual Monitor Manager"
      @tray.signal_connect('popup-menu') do |w, button, activate_time|
        Dumon::logger.info "Terminted..."
        Gtk.main_quit
      end
    end

  end

end
