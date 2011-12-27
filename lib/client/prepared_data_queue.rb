require_relative 'prepared_data_row'

module Filial
  class PreparedDataQueue
    def queue_next_by(trackings_queue)
      trackings = trackings_queue.trackings

      #PreparedDataRow.create

      trackings_queue.clear!
    end

    def remove_acknowledged_data!(list)
    end
  end
end
