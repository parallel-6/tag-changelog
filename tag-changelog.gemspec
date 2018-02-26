# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','tag_changelog','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'tag-changelog'
  s.version = TagChangelog::VERSION
  s.license = 'MIT'
  s.author = 'Parallel6'
  s.email = 'contact@parallel6.com'
  s.homepage = 'https://github.com/parallel-6/tag-changelog'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Tool to generate changelog based on Parallel6 specs'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = []
  s.rdoc_options << '--title' << 'tag-changelog' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'tag-changelog'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('pry')
  s.add_runtime_dependency('gli','2.17.1')
end
