require_relative '../../shared/model_shared_methods'

module Central
  class SavedPreparedID
    include DataMapper::Resource
    extend Shared::ModelSharedMethods

    property :id,       Serial
    property :saved_id, Integer, :index => true
  end
end

ENV['TEST'] ? DataMapper.auto_migrate! : DataMapper.auto_upgrade!
