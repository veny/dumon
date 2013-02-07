# dumon

Dual monitor manager for Linux with GTK2 based user interface represented by system tray icon and its context menu.

## SCREENSHOTS

[![](https://raw.github.com/veny/dumon/master/screenshots/tray_icon.png)](https://raw.github.com/veny/dumon/master/screenshots/tray_icon.png)

[![](https://raw.github.com/veny/dumon/master/screenshots/basic_menu.png)](https://raw.github.com/veny/dumon/master/screenshots/basic_menu.png)

[![](https://raw.github.com/veny/dumon/master/screenshots/resolution_menu.png)](https://raw.github.com/veny/dumon/master/screenshots/resolution_menu.png)

[![](https://raw.github.com/veny/dumon/master/screenshots/mirror_menu.png)](https://raw.github.com/veny/dumon/master/screenshots/mirror_menu.png)


## USAGE
### INSTALL
 > sudo gem install dumon

* gem published on http://rubygems.org/gems/dumon

### START
 > ruby -r dumon -e 'Dumon::run'

* or add GEM PATH (see 'gem environment') into your PATH and then

 > dumon

* or as daemon process

 > ruby -r dumon -e 'Dumon::run true'

 > dumon --daemon

### UPGRADE NOTICES

* see lib/dumon/version.rb

### CONFIGURATION

#### Logger

* by default to 'STDOUT' on level 'INFO'

 > Dumon.logger = Logger.new('/tmp/log.txt')

 > Dumon.logger.level = Logger::DEBUG


## FEATURES/PROBLEMS

* only for Linux
* currently supports only two output devices
* currently works only with 'xrandr' (command line interface to RandR extension)

## REQUIREMENTS

* Ruby 1.9.x
* ruby-gtk2 1.2.x
* xrandr 1.3.x

## AUTHOR

* vaclav.sykora@gmail.com
* https://plus.google.com/115674031373998885915

## LICENSE

* Apache License, Version 2.0, http://www.apache.org/licenses/
* see LICENSE file for more details...
