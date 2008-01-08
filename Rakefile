require 'rake/gempackagetask'
require 'rubygems'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :spec


PKG_VERSION="0.2.0"
PKG_FILES=["AUTHORS","lib/hpricot_ext.rb","lib/lilu.rb","lib/lilu_view.rb","lib/lilu_camping.rb","spec/lilu_spec.rb"]

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "View subsystem that allows to keep pure HTML for views"
  s.name = 'lilu'
  s.version = PKG_VERSION
  s.requirements << 'hpricot'
  s.require_path = 'lib'
  s.autorequire = ['rake','hpricot','lib/hpricot_ext','lib/lilu','lib/lilu_view','lib/lilu_camping']
  s.files = PKG_FILES
  s.authors = [ "Yurii Rashkovskii" ]
  s.email = "yrashk@verbdev.com"
  s.description = "View subsystem that allows to keep pure HTML for views"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Run all specifications"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/*.rb']
end
