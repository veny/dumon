module Dumon

  ###
  # This class represents a base class defining user interface
  # (dialog window) for profile management.
  class ProfileDlg

    ###
    # Constructor.
    def initialize
      @dumon_conf = Dumon::App.instance.read_config
    end

    ###
    # Shows the dialog.
    # Abstract method to be overridden by concrete sub-class.
    def show
      raise NotImplementedError, 'this should be overridden by concrete sub-class'
    end

    ###
    # Reacts to an problem by profile use with a warning.
    # *msg* message describing the problem
    def on_warn(msg)
      Dumon::logger.warn msg.join(', ')
    end

    ###
    # Applies a profile from configuration according selection in tree view.
    # *prof_name* profile name
    def apply_profile(prof_name)
      profile = @dumon_conf[:profiles][prof_name.to_sym]
      profile[:mode] = profile[:mode].to_sym
      begin
        Dumon::App.instance.ui.omanager.switch profile
        Dumon::logger.debug "Profile applied, name=#{prof_name}"
      rescue ArgumentError => ae # BF #14
        on_warn ['Profile use failed! (unconnected output?)', "profile name=#{prof_name}", "message=#{ae.message}"]
      end
    end

  end


  ###
  # This class represents an user interface for profile management based on Gtk library.
  class GtkProfileDlg < ProfileDlg

    ###
    # Constructor.
    def initialize
      super

      # create the dialog
      @dialog = Gtk::Dialog.new('Profile management', nil, Gtk::Dialog::MODAL, [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT])
      t = Gtk::Table.new(2, 2)
      t.row_spacings = 5
      t.column_spacings = 5

      # disable entry/button if no mode set (probably after start of Dumon)
      entry_store = Gtk::Entry.new
      btn_save = Gtk::Button.new(Gtk::Stock::SAVE)
      if Dumon::App.instance.current_profile.nil?
        entry_store.text = '<make a choice first>'
        entry_store.set_sensitive false
        btn_save.set_sensitive false
      end

      # save new profile
      btn_save.signal_connect('clicked') do
        if entry_store.text.size > 0
          @dumon_conf[:profiles][entry_store.text] = Dumon::App.instance.current_profile
          Dumon::App.instance.write_config(@dumon_conf)
          Dumon::logger.debug "Stored profile, name=#{entry_store.text}"
          @dialog.destroy
        end
      end

      t.attach(Gtk::HBox.new(false, 5).pack_start(Gtk::Label.new('Profile name:'), false, false).add(entry_store), 0, 1, 0, 1)
      t.attach(btn_save, 1, 2, 0, 1)

      # select/delete existing profile
      model = Gtk::ListStore.new(String)
      treeview = Gtk::TreeView.new(model)
      treeview.headers_visible = false
      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new('', renderer, :text => 0)
      treeview.append_column(column)

      @dumon_conf[:profiles].keys.each do |k|
        iter = model.append
        iter.set_value 0, k.to_s
      end

      # apply
      btn_apply = Gtk::Button.new(Gtk::Stock::APPLY)
      btn_apply.signal_connect('clicked') do
        selection = treeview.selection
        if iter = selection.selected
          apply_profile(iter[0])
          @dialog.destroy
        end
      end
      # double-click on treeview
      treeview.signal_connect("row-activated") do |view, path|
        if iter = view.model.get_iter(path)
          apply_profile(iter[0])
          @dialog.destroy
        end
      end
      # delete
      btn_delete = Gtk::Button.new(Gtk::Stock::DELETE)
      btn_delete.signal_connect('clicked') do
        selection = treeview.selection
        if iter = selection.selected
          prof_name = iter[0]
          @dumon_conf[:profiles].delete prof_name.to_sym
          Dumon::App.instance.write_config(@dumon_conf)
          Dumon::logger.debug "Deleted profile, name=#{prof_name}"
          @dialog.destroy
        end
      end

      t.attach(treeview, 0, 1, 1, 2)
      t.attach(Gtk::VBox.new(false, 5).pack_start(btn_apply, false, false).pack_start(btn_delete, false, false), 1, 2, 1, 2)

      @dialog.vbox.add t

      # ensure that the dialog box is destroyed when the user responds
      @dialog.signal_connect('response') do |w, code|
        if Gtk::Dialog::RESPONSE_OK.eql?(code) and entry.text.size > 0
          Dumon::App.instance.write(entry.text => Dumon::App.instance.current_profile)
        end

        @dialog.destroy
      end
    end

    def show #:nodoc:
      @dialog.show_all
    end

    def on_warn(msg) #:nodoc:
      super(msg)
      md = Gtk::MessageDialog.new(
          @dialog,
          Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::WARNING,
          Gtk::MessageDialog::BUTTONS_CLOSE,
          msg.join("\n"))
      md.run
      md.destroy
    end

  end

end
