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

    def initialize #:nodoc:
      super

      @tray = Gtk::StatusIcon.new
      @tray.visible = true
      @tray.pixbuf = Gdk::Pixbuf.new(::File.join(::File.dirname(__FILE__), '..', '..', 'img', 'monitor.png'))
      @tray.tooltip = "Dual Monitor Manager"

      @tray.signal_connect('popup-menu') do |w, button, activate_time|
        menu = self.create_menu
        menu.show_all
        menu.popup(nil, nil, button, activate_time)
      end
    end


      def create_menu
        rslt = Gtk::Menu.new
        outputs = self.screen.read

        # outputs
        outputs.keys.each do |o|
          item = Gtk::MenuItem.new(o)
          defres = self.default_resolution(outputs[o])
          item.signal_connect('activate') do
            self.screen.switch(o, defres)
          end
          rslt.append(item)
        end

        # separator
        item = Gtk::SeparatorMenuItem.new
        rslt.append(item)
        # Quit
        item = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
        item.signal_connect('activate') { self.quit }
        rslt.append(item)

        rslt
      end

      def default_resolution(output)
        output.each { |res| return res[0..-2] if res.end_with?('*') }
        raise 'no default resolution found'
      end

  end

end
