ROOT_DIR = ::File.expand_path('../../..',  __FILE__)
AUX_DB  = "#{ROOT_DIR}/client_aux.sqlite3"
TEST_DB = "#{ROOT_DIR}/testdb.sqlite3"

require 'data_mapper'

DataMapper::Logger.new($stdout, :error)

if ENV['TEST']
  DataMapper.setup(:default, "sqlite://#{TEST_DB}") #'sqlite::memory:')
else
  DataMapper.setup(:default, "sqlite://#{AUX_DB}")
end

DataMapper::Property.required(true)
