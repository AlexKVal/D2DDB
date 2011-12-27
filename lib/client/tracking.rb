require 'data_mapper'

DataMapper::Logger.new($stdout, :debug) #:error

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

    def self.clear!
      repository(:default).adapter.select("DELETE FROM #{storage_name}")
    end
  end
end

DataMapper.auto_upgrade!
#DataMapper.auto_migrate! if ENV['TEST'] || !File.exists?(AUX_DB)
