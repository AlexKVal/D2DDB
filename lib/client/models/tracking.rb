require_relative '../../shared/model_shared_methods'

module Filial
  class Tracking
    include DataMapper::Resource
    extend Shared::ModelSharedMethods

    property :id,      Serial
    property :tblname, String,  :index => true, :length => 32
    property :rowid,   Integer, :index => true
    property :action,  String,  :length => 1 # I U D
  end
end

ENV['TEST'] ? DataMapper.auto_migrate! : DataMapper.auto_upgrade!
