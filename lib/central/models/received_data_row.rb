require_relative '../../shared/model_shared_methods'

module Central
  class ReceivedDataRow
    include DataMapper::Resource
    extend Shared::ModelSharedMethods

    property :id,      Serial
    property :tblname, String,  :index => true, :length => 32
    property :rowid,   Integer, :index => true
    property :action,  String,  :length => 1 # I U D
    property :data,    String,  :length => 1500, :required => false
  end
end

ENV['TEST'] ? DataMapper.auto_migrate! : DataMapper.auto_upgrade!
