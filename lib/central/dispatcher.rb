require_relative 'applier'

module Central
  # Front object for DRb on server side
  class Dispatcher
    def initialize(rdq = ReceivedDataQueue.new, appl = Applier.new)
      @received_data_queue = rdq
      @applier = appl
    end

    def process_filial_data(filial_id, incoming_data)
      puts "\nReceived data: #{incoming_data.size} for filial: #{filial_id}"
      puts "#{'='*60}"
      saved_ids = @received_data_queue.save(incoming_data)
      puts "#{'='*60}"

      puts "\nProcessing data for filial: #{filial_id}"
      puts "#{'='*60}"
      @applier.run
      puts "#{'='*60}"

      saved_ids
    end
  end
end
