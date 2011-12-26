require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)

if ENV['TEST']
  DataMapper.setup(:default, 'sqlite::memory:')
else
  DataMapper.setup(:default, "sqlite://#{AUX_DB}")
end

DataMapper::Property.required(true)

module Filial
  class Tracking
    include DataMapper::Resource

    property :id,      Serial
    property :tblname, String,  :index => true, :length => 32
    property :rowid,   Integer, :index => true
    property :action,  String,  :length => 1 # I U D
  end
end

DataMapper.auto_migrate! if ENV['TEST'] || !File.exists?(AUX_DB)
