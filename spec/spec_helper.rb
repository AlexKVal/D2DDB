require 'rubygems'
require 'rbconfig'

begin
  require 'spork'
rescue LoadError
  module Spork
    def self.prefork
      yield
    end

    def self.each_run
      yield
    end
  end
end

Spork.prefork do
  ENV['TEST'] = 'True'

  require "client"
  require "applier"

  Pvsw.odbc_alias = "TestDB.NET"


  Dir['./spec/support/**/*.rb'].map {|f| require f}

  RSpec.configure do |c|
    c.treat_symbols_as_metadata_keys_with_true_values = true

    if RbConfig::CONFIG['target_os'] =~ /darwin/i
      c.filter_run_excluding(:pvsw)
    end
    #c.filter_run_including(:pvsw)

    # c.include FakeFS::SpecHelpers, :fakefs
  end
end

Spork.each_run do
end
