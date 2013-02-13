source :rubygems

gem 'sinatra',         '~>1.3', :require => 'sinatra/base'
gem 'sinatra-contrib', '~>1.3'
gem 'activerecord',    '~>3.2.0'
gem 'activesupport',   '~>3.2.0'
gem 'sqlite3'
gem 'warden',          '~>1.1'

group :development do
  gem 'shotgun'
  gem 'pry', '0.9.10'       # 0.9.11.4 does not work with pry-stack_explorer 0.4.7
  gem 'pry-stack_explorer', :require => false
  gem 'minitest'
end

Dir[File.join(File.dirname(__FILE__), "plugins", "**", "Gemfile")].each do |plugin_gemfile|
  eval(IO.read(plugin_gemfile), binding)
end
