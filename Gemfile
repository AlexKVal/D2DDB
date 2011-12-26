source 'http://rubygems.org'

gem "ruby-odbc"

group :development, :test do
  gem "rspec"

  require 'rbconfig'
  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    #gem 'interactive_rspec'
    gem "guard-rspec", "0.5.0"
    gem "growl", "1.0.3"
    gem "spork", "0.9.0.rc9"
    gem "rb-fsevent", "~> 0.4.3.1"
  end
end
