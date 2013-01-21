module Dumon

  ###
  # This class represents Dumon's user interface.
  class Ui

    attr_accessor :screen

  end

  ###
  # This class represents a user interface represented by system tray icon and its context menu.
  # about outputs available on your system look like.
  class Tray < Ui

    def initialize
      @tray = Gtk::StatusIcon.new
      @tray.stock = Gtk::Stock::DIALOG_INFO
      @tray.visible = true
      @tray.signal_connect('popup-menu') do |w, button, activate_time|
        Gtk.main_quit
      end
    end

  end

end
