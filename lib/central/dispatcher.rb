require_relative 'applier'

module Central
  # Front object for DRb on server side
  class Dispatcher
    def initialize(rdq = ReceivedDataQueue.new,
                   appl = Applier.new(CENTRAL_ALIAS))
      @received_data_queue = rdq
      @applier = appl
    end

    def process_filial_data(filial_id, incoming_data)
      unless incoming_data.size == 0
        LOG.debug "Dispatcher.process_filial_data"

        LOG.info "Incoming data: #{incoming_data.size} for filial: #{filial_id}"
        saved_ids = @received_data_queue.save(incoming_data)

        LOG.info "Processing data for filial: #{filial_id}"
        @applier.run

        return saved_ids
      else
        LOG.info "Empty incoming data from filial: #{filial_id}"

        return []
      end
    end
  end
end
