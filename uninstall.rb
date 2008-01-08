require 'fileutils'
begin
  FileUtils.rm_f(RailsEnvironment.default.root + '/script/mockup_server')
rescue
  puts "Problem while uninstalling Lilu plugin: #{$!}"
end