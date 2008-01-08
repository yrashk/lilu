namespace :lilu do
  desc "Install Lilu plugin (mockup_server)"
  task :install do 
    ENV['RAILS_ROOT'] = File.dirname(__FILE__)+'/../../../../' 
    `ruby #{File.dirname(__FILE__)}/../install.rb`
  end
end