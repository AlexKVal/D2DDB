require 'drb'

module Filial
  class Exchanger
    def initialize
      DRb.start_service
      @remote_object = DRbObject.new_with_uri SERVER_URI
    end

    def send(prepared_data_queue)
      data_to_transmit = []
      prepared_data_queue.data.each do |pdr|
        data_to_transmit << [pdr.id, pdr.tblname, pdr.rowid, pdr.action, pdr.data]
      end
      acknowledged_ids = @remote_object.process_filial_data(FILIAL_ID, data_to_transmit)
      prepared_data_queue.remove_acknowledged_data!(acknowledged_ids)
    end
  end
end
