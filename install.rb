require 'fileutils'
begin
  begin
    @rails_root = ENV['RAILS_ROOT'] || RAILS_ROOT
  rescue NameError
    @rails_root = RailsEnvironment.default.root
  end
  FileUtils.symlink(File.dirname(__FILE__) + '/bin/mockup_server', @rails_root   + '/script/mockup_server')
rescue
  puts "Problem while installing Lilu plugin: #{$!}"
end