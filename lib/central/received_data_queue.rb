require_relative 'models/received_data_row'

module Central
  class ReceivedDataQueue
    def data
      ReceivedDataRow.all
    end

    # returns an array of saved ids
    def save(received_data)
      LOG.debug "ReceivedDataQueue.save"

      saved_ids = []
      received_data.each do |row|
        LOG.debug "saving received data: #{row[1]} #{row[2]} #{row[3]}"
        saved_ids << row[0]
        ReceivedDataRow.create!(
          tblname: row[1],
          rowid:   row[2],
          action:  row[3],
          data:    row[4]
        )
      end
      saved_ids
    end

    def clear!
      LOG.debug "ReceivedDataQueue.clear!"
      ReceivedDataRow.clear!
    end
  end
end
