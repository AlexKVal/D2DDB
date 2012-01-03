require_relative 'applier'

module Central
  # Front object for DRb on server side
  class Dispatcher
    def initialize(rdq = ReceivedDataQueue.new,
                   appl = Applier.new(CENTRAL_ALIAS))
      @received_data_queue = rdq
      @applier = appl
    end

    def receive_filial_data(filial_id, incoming_data, &block)
      unless incoming_data.size == 0
        LOG.info "Incoming data: #{incoming_data.size} for filial: #{filial_id}"
        LOG.debug "Dispatcher.receive_filial_data incoming_data=#{incoming_data.inspect}"

        received_ids = incoming_data.inject([]) {|ids, row| ids << row[0]}

        # the client waits ids of received rows as an acknowledge
        # and returns just 'ok' as a signal that connection has not been broken.
        LOG.debug "yield received_ids=#{received_ids.inspect}. Next has to be answer !"
        answer = yield received_ids
        LOG.debug "got answer=#{answer}"

        if answer
          LOG.info "Processing data for filial: #{filial_id}"

          @received_data_queue.save(incoming_data)

          @applier.run
        else
          LOG.info "Dispatcher.receive_filial_data problems w/ connection ?"
        end
      else
        LOG.info "Empty incoming data from filial: #{filial_id}"
      end

      LOG.info "== The end of processing received data for filial: #{filial_id}"
    end
  end
end
