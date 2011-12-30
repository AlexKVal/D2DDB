# Client-side
FILIAL_ID = 'Chab' # used for distinguish connections on server-side

# Server-side
CENTRAL_ALIAS = "CentrChab.NET" # alias for filial db on central server
CENTRAL_PREFIX = 'Chab' # prefix for tables

ROOT_DIR = ::File.expand_path('../..',  __FILE__)

# require 'rbconfig'
# if RbConfig::CONFIG['target_os'] =~ /darwin/i
  AUX_DB  = "#{ROOT_DIR}/auxdb.sqlite3"
  TEST_DB = "#{ROOT_DIR}/testdb.sqlite3"
# else
#   p ROOT_DIR
#   AUX_DB  = "c:/auxdb.sqlite3"
#   TEST_DB = "c:/testdb.sqlite3"
# end

require 'data_mapper'

DataMapper::Logger.new($stdout, :error)

if ENV['TEST']
  DataMapper.setup(:default, "sqlite://#{TEST_DB}") #'sqlite::memory:')
else
  DataMapper.setup(:default, "sqlite://#{AUX_DB}")
end

DataMapper::Property.required(true)
