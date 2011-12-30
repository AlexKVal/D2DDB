require_relative "../config"

ROOT_DIR = ::File.expand_path('../..',  __FILE__)

require 'data_mapper'

DataMapper::Logger.new($stdout, :error)

if ENV['TEST']
  DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/testdb.sqlite3")
else
  raise "SIDE must be set to 'server' or 'client'" unless %w(central filial).include? SIDE
  DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/#{SIDE}_db.sqlite3")
end

DataMapper::Property.required(true)
