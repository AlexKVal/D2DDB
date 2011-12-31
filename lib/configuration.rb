require_relative "../config"
require 'logger'

ROOT_DIR = ::File.expand_path('../..',  __FILE__)

require 'data_mapper'

DataMapper::Logger.new($stdout, :error)

if ENV['TEST']
  DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/testdb.sqlite3")
  logfname = "#{ROOT_DIR}/logs/tests_log.txt"
  File.delete(logfname) if File.exists?(logfname)
  LOG = Logger.new(logfname)
else
  raise "SIDE must be set to 'server' or 'client'" unless %w(central filial).include? SIDE
  DataMapper.setup(:default, "sqlite://#{ROOT_DIR}/#{SIDE}_db.sqlite3")
  LOG = LOG_FILENAME ? Logger.new("#{SIDE}_#{LOG_FILENAME}", 5, 1024000) : Logger.new($stdout)
end

DataMapper::Property.required(true)

LOG.level = LOG_VERBOSE ? Logger::DEBUG : Logger::INFO

LOG.formatter = proc { |severity, datetime, progname, msg|
  "#{datetime}: #{msg}\n"
}
