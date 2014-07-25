source "https://rubygems.org/"

gem 'sinatra'
gem "rack-timeout"

gem 'mongoid', '3.0.23'
gem 'bson_ext'
gem 'mongoid_auto_increment'

gem 'whenever', :require => false
gem 'resque'
gem 'redis'
gem 'resque-scheduler'

gem 'haml'
gem 'capybara', '2.2.1'
gem 'capybara-webkit', '1.1.0'
gem 'activesupport', '3.2.17'
gem "will_paginate"
gem "will_paginate_mongoid"
gem "will_paginate-bootstrap"
gem 'activerecord'
gem 'mysql2'


platforms :ruby do # linux
  gem 'unicorn'
end

group :development do
  gem 'shotgun'
  gem 'tux'
  gem 'debugger'
  gem 'capistrano'
end



group :test do
  gem 'rspec'
end
