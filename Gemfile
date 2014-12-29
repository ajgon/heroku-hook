source 'https://rubygems.org'
ruby '1.9.3'

gem 'git'
gem 'rake'
gem 'foreman'
gem 'foreman-export-nginx'
gem 'dotenv'

group :development do
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'reek', require: false
  gem 'overcommit', require: false
  gem 'gemsurance', require: false
  gem 'sandi_meter', require: false
  gem 'travis-lint', require: false
end

group :test do
  gem 'rspec'
  gem 'simplecov', require: false

  # Code quality
  gem 'codeclimate-test-reporter', require: false
end
