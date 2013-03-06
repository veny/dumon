module Dumon

  ###
  # This class represents Dumon's user interface.
  class Ui

    ###
    # Output manager used to manipulate the output.
    attr_reader :omanager

    ###
    # Constructor.
    def initialize
      @omanager = new_omanager
      Dumon::logger.debug "Used output manager: #{omanager.class.name}"
    end

    ###
    # Factory method to create a new object of output manager.<p/>
    # Can be used as Dependency Injection (DI) entry point:
    # you can reopen Dumon:Ui and redefine 'new_omanager' if you implement a new output manager.
    # <pre>
    # class Dumon::Ui
    #   def new_omanager; Dumon::XyManager.new; end
    # end
    # </pre>
    def new_omanager(with=Dumon::XrandrManager)
      with.new
    end

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

    ###
    # Provides information about the app.
    def about
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
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

    def about #:nodoc:
      about = Gtk::AboutDialog.new
      about.set_program_name 'Dumon'
      about.set_version Dumon::VERSION
      about.set_copyright "(c) Vaclav Sykora"
      about.set_comments 'Dual monitor manager'
      about.set_website 'https://github.com/veny/dumon'
      about.set_logo Gdk::Pixbuf.new(::File.join(::File.dirname(__FILE__), '..', 'monitor48.png'))
      about.run
      about.destroy
    end

  end


  ###
  # This class represents a user interface represented by system tray icon and its context menu.
  class GtkTrayUi < GtkUi

    def initialize #:nodoc:
      super

      # storage of preferred resolution for next rendering (will be cleared by output changing)
      # {"LVDS1" => "1600x900", "VGA1" => "800x600"}
      @selected_resolution = {}

      @tray = Gtk::StatusIcon.new
      @tray.visible = true
      @tray.pixbuf = Gdk::Pixbuf.new(::File.join(::File.dirname(__FILE__), '..', 'monitor24.png'))
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

      # single outputs
      outputs.keys.each do |o|
        item = Gtk::MenuItem.new("only #{o}")
        item.signal_connect('activate') do
          self.omanager.switch({:mode=>:single, :out=>o, :resolution=>@selected_resolution[o]})
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
        end
        rslt.append(item)
      end

      # mirror
      item = Gtk::MenuItem.new('mirror')
      if outputs.keys.size >= 2
        submenu = Gtk::Menu.new
        item.set_submenu(submenu)
      else
        item.sensitive = false
      end

      self.omanager.common_resolutions.each do |res|
        si = Gtk::MenuItem.new(res)
        si.signal_connect('activate') { self.omanager.switch({:mode=>:mirror, :resolution=>res}) }
        submenu.append(si)
      end
      rslt.append(item)

      # separator
      item = Gtk::SeparatorMenuItem.new
      rslt.append(item)

      # primary output
      item = Gtk::MenuItem.new('primary output')
      submenu = Gtk::Menu.new
      item.set_submenu(submenu)
      item.sensitive = (outputs.keys.size >= 2)

      radios = []
      prims = outputs.keys.clone << :none
      prims.each do |o|
        si = Gtk::RadioMenuItem.new(radios, o.to_s)
        si.active = (App.instance.primary_output.to_s == o.to_s)
        radios << si
        si.signal_connect('activate') { App.instance.primary_output = o.to_s if si.active? }
        submenu.append(si)
      end
      rslt.append(item)

      # sequence
      if outputs.keys.size >= 2
        o0 = outputs.keys[0]
        o1 = outputs.keys[1]
        item = Gtk::MenuItem.new("#{o0} left of #{o1}")
        item.signal_connect('activate') do
          omanager.switch({:mode=>:sequence, :outs=>[o0, o1], :resolutions=>[@selected_resolution[o0], @selected_resolution[o1]], :primary=>@primary})
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
        end
        rslt.append(item)
        item = Gtk::MenuItem.new("#{o1} left of #{o0}")
        item.signal_connect('activate') do
          omanager.switch({:mode=>:sequence, :outs=>[o1, o0], :resolutions=>[@selected_resolution[o1], @selected_resolution[o0]], :primary=>@primary})
          # clear preferred resolution, by next rendering will be read from real state
          @selected_resolution.clear
        end
        rslt.append(item)
      end

      # separator
      item = Gtk::SeparatorMenuItem.new
      rslt.append(item)
      # About
      item = Gtk::ImageMenuItem.new(Gtk::Stock::ABOUT)
      item.signal_connect('activate') { self.about }
      rslt.append(item)
      # Quit
      item = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
      item.signal_connect('activate') { self.quit }
      rslt.append(item)

      rslt
    end

  end

end
