module Central
  class SavedPreparedID
    include DataMapper::Resource

    property :id,       Serial
    property :saved_id, Integer, :index => true

    def self.clear!
      repository(:default).adapter.select("DELETE FROM #{storage_name}")
    end
  end
end

ENV['TEST'] ? DataMapper.auto_migrate! : DataMapper.auto_upgrade!
