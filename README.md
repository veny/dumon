           ____
          |  _ \ _   _ _ __ ___   ___  _ __
          | | | | | | | '_ ` _ \ / _ \| '_ \
          | |_| | |_| | | | | | | (_) | | | |
          |____/ \__,_|_| |_| |_|\___/|_| |_|


Dual monitor manager for Linux with GTK based user interface represented by system tray icon's context menu.

## SCREENSHOTS

[![](https://raw.github.com/veny/dumon/master/screenshots/tray_icon.png)](https://raw.github.com/veny/dumon/master/screenshots/tray_icon.png)

[![](https://raw.github.com/veny/dumon/master/screenshots/basic_menu.png)](https://raw.github.com/veny/dumon/master/screenshots/basic_menu.png)

[![](https://raw.github.com/veny/dumon/master/screenshots/resolution_menu.png)](https://raw.github.com/veny/dumon/master/screenshots/resolution_menu.png)

[![](https://raw.github.com/veny/dumon/master/screenshots/mirror_menu.png)](https://raw.github.com/veny/dumon/master/screenshots/mirror_menu.png)


## FEATURES/PROBLEMS

* only for Linux
* dynamical detection of currently connected output devices
* support for storing profiles
* configurable shell command running after each switch of output
* currently supports only two output devices
* currently works only with 'xrandr' (command line interface to RandR extension)


## USAGE
### INSTALL
 > sudo gem install dumon

* gem published on http://rubygems.org/gems/dumon

### START
 > ruby -r dumon -e 'Dumon::App.instance.run'

* or add GEM PATH (see 'gem environment') into your PATH and then

 > dumon

* or as daemon process

 > ruby -r dumon -e 'Dumon::App.instance.run true'

 > dumon --daemon

* start with given profile

 > ruby -r dumon -e 'Dumon::App.instance.run' -s 'profile:Profile name'

* or

 > dumon 'profile:Profile name'

### UPGRADE NOTICES

* see lib/dumon/version.rb

### CONFIGURATION

#### Logger

* by default to 'STDOUT' on level 'INFO'

 > Dumon.logger = Logger.new('/tmp/log.txt')

 > Dumon.logger.level = Logger::DEBUG

 #### Post Switch Command

 * you can define a shell command that will be executed after each switch of output
 * just insert _post_switch_ key into _$HOME/.config/dumon.conf_ like this

 ```
{
  "version": "0.2.8",
  "post_switch": "feh --bg-scale /usr/share/archlinux/wallpaper/archlinux-firestarter.jpg; killall conky; conky"
}
```


 ## REQUIREMENTS

* Ruby 1.8.7 +
* ruby-gtk2 1.2.x +
* xrandr 1.3.x +

## AUTHOR

* vaclav.sykora@gmail.com
* https://plus.google.com/115674031373998885915

## LICENSE

* Apache License, Version 2.0, http://www.apache.org/licenses/
* see LICENSE file for more details...
