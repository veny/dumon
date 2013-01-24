module Dumon

  ###
  # This class represents Dumon's user interface.
  class Ui

    ###
    # Output manager used to manipulate the outputs.
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

      # storage of preferred resolution for next rendering (will be cleared by output changing)
      # {"LVDS1" => "1600x900", "VGA1" => "800x600"}
      @selected_resolution = {}

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

    ###
    # Reads info about currently usable outputs and construct corresponding structure of context menu.
    def create_menu
      outputs = self.screen.read

      rslt = Gtk::Menu.new

      # resolutions (submenu)
      outputs.keys.each do |o|
        item = Gtk::MenuItem.new(o)
        submenu = Gtk::Menu.new
        item.set_submenu(submenu)

        # to be marked with '*'
        defres = self.screen.default_resolution(o)

        # radio buttons group
        radios = []

        outputs[o][:resolutions].each do |res|
          si = Gtk::RadioMenuItem.new(radios, defres === res ? "#{res} *" : res)
          si.active = (@selected_resolution[o] === res or (@selected_resolution[o].nil? and outputs[o][:current] === res))
          radios << si
          si.signal_connect('activate') do
            # only store your preferred resolution for next rendering
            @selected_resolution[o] = res if si.active? # only activation, ignore deactivation
          end
          submenu.append(si)
        end
        rslt.append(item)
      end

      # separator
      item = Gtk::SeparatorMenuItem.new
      rslt.append(item)

      # outputs
      outputs.keys.each do |o|
        item = Gtk::MenuItem.new("only #{o}")
        item.signal_connect('activate') do
          self.screen.switch(o, @selected_resolution[o])
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
        end
        rslt.append(item)
      end

      # mirror
      item = Gtk::MenuItem.new('mirror')
      submenu = Gtk::Menu.new
      item.set_submenu(submenu)

      self.screen.common_resolutions.each do |res|
        si = Gtk::MenuItem.new(res)
        si.signal_connect('activate') { self.screen.mirror(res) }
        submenu.append(si)
      end
      rslt.append(item)

      # separator
      item = Gtk::SeparatorMenuItem.new
      rslt.append(item)
      # Quit
      item = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
      item.signal_connect('activate') { self.quit }
      rslt.append(item)

      rslt
    end

  end

end
