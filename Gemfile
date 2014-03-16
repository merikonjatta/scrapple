source :rubygems

gem 'sinatra',         '~>1.0', :require => 'sinatra/base'
gem 'sinatra-contrib', '~>1.0'
gem 'activesupport',   '~>3.2.0'

group :development do
  gem 'yard'
  gem 'rake'
  gem 'shotgun'
  gem 'rerun'
  gem 'rb-fsevent', '~>0.9.0'
  gem 'pry'
  gem 'pry-stack_explorer', :require => false
  gem 'minitest'
  gem 'unindent'
end

# Load all Gemfiles from plugins
# TODO ability to change plugin dir
Dir[File.join(File.dirname(__FILE__), "plugins", "**", "Gemfile")].each do |plugin_gemfile|
  eval(IO.read(plugin_gemfile), binding)
end
