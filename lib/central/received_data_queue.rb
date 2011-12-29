require_relative 'models/received_data_row'
require_relative 'models/saved_prepared_id'

module Central
  class ReceivedDataQueue

    def saved_prepared_ids
      SavedPreparedID.all.map(&:saved_id)
    end

    #when sent acknowledge to Filial
    def clear_prepared_ids
      SavedPreparedID.clear!
    end

    def data
      ReceivedDataRow.all
    end

    def save(received_data)
      received_data.each do |row|
        puts "saving received data: #{row[1]} #{row[2]} #{row[3]}"
        SavedPreparedID.create(saved_id: row[0])
        ReceivedDataRow.create!(
          tblname: row[1],
          rowid:   row[2],
          action:  row[3],
          data:    row[4]
        )
      end
    end

  end
end
