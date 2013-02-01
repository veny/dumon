module Dumon

  ###
  # This class represents Dumon's user interface.
  class Ui

    ###
    # Output manager used to manipulate the output.
    attr_accessor :omanager

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
      outputs = self.omanager.read

      rslt = Gtk::Menu.new

      # resolutions (submenu)
      outputs.keys.each do |o|
        item = Gtk::MenuItem.new(o)
        submenu = Gtk::Menu.new
        item.set_submenu(submenu)

        # to be marked with '*'
        defres = self.omanager.default_resolution(o)

        # radio buttons group
        radios = []

        outputs[o][:resolutions].each do |res|
          si = Gtk::RadioMenuItem.new(radios, defres === res ? "#{res} [*]" : res)
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
          self.omanager.single(o, @selected_resolution[o])
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
        end
        rslt.append(item)
      end

      # mirror
      item = Gtk::MenuItem.new('mirror')
      if outputs.keys.size > 1
        submenu = Gtk::Menu.new
        item.set_submenu(submenu)
      else
        item.sensitive = false
      end

      self.omanager.common_resolutions.each do |res|
        si = Gtk::MenuItem.new(res)
        si.signal_connect('activate') { self.omanager.mirror(res) }
        submenu.append(si)
      end
      rslt.append(item)

      # sequence (currently supporting only 2 output devices)
      if outputs.keys.size >= 2
        o0 = outputs.keys[0]
        o1 = outputs.keys[1]
        item = Gtk::MenuItem.new("#{o0} left of #{o1}")
        item.signal_connect('activate') do
          self.omanager.sequence([[o0, @selected_resolution[o0]], [o1, @selected_resolution[o1]]])
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
        end
        rslt.append(item)
        item = Gtk::MenuItem.new("#{o1} left of #{o0}")
        item.signal_connect('activate') do
          self.omanager.sequence([[o1, @selected_resolution[o1]], [o0, @selected_resolution[o0]]])
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
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

  end

end
