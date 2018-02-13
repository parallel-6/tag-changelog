# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','changelog','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'changelog'
  s.version = Changelog::VERSION
  s.author = 'Parallel6'
  s.email = 'contact@parallel6.com'
  s.homepage = 'http://clinical6.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Tool to generate changelog based on Parallel6 specs'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','changelog.rdoc']
  s.rdoc_options << '--title' << 'changelog' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'changelog'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('pry')
  s.add_runtime_dependency('gli','2.17.1')
end
