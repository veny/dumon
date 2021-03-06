# -*- encoding: utf-8 -*-

$:.unshift File.expand_path('../lib', __FILE__)
require 'dumon/version'

Gem::Specification.new do |s|

  s.name = %q{dumon}
  s.version = Dumon::VERSION

  s.required_rubygems_version = Gem::Requirement.new('> 1.3.1') if s.respond_to? :required_rubygems_version=
  s.authors = ['Vaclav Sykora']
  s.date = Dumon::VERSION_HISTORY[0][1]
  s.description = %q{Dual monitor manager for Linux with GTK based user interface represented by system tray icon's context menu.}
  s.email = %q{vaclav.sykora@gmail.com}

  s.files         = `git ls-files`.split("\n").select { |item| item unless item.start_with? 'screenshot' }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.homepage = %q{http://github.com/veny/dumon}
  s.rdoc_options = ['--charset=UTF-8']
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Dual monitor manager for Linux.}
  s.license = 'Apache License, v2.0'

  s.add_runtime_dependency 'gtk2', '~> 2.2', '>= 2.2.0'
end
