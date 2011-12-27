module Filial
  class PreparedDataRow
    include DataMapper::Resource

    property :id,      Serial
    property :tblname, String,  :index => true, :length => 32
    property :rowid,   Integer, :index => true
    property :action,  String,  :length => 1 # I U D

    property :data,    String,  :length => 1000

    def self.clear!
      repository(:default).adapter.select("DELETE FROM #{storage_name}")
    end
  end
end

ENV['TEST'] ? DataMapper.auto_migrate! : DataMapper.auto_upgrade!
