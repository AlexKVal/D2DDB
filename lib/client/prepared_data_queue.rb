require_relative 'models/prepared_data_row'
require_relative '../shared/pvsw'

module Filial
  class PreparedDataQueue
    def data
      @data ||= PreparedDataRow.all
    end

    def queue_next_by(trackings_queue)
      get_data_for(trackings_queue.trackings)

      saves_data_as_prepared_data_rows

      trackings_queue.clear!
    end

    def remove_acknowledged_data!(acknowledged_ids)
      acknowledged_ids.each do |id|
        PreparedDataRow.get(id).destroy
      end
      @data = nil
    end

    private
      def get_data_for(trackings)
        #[[table, rowid, action, json_data], [..]]
        @data_to_queue = []
        ODBC::connect(Pvsw.odbc_alias) do |dbc|
          pvsw = Pvsw.new(dbc)

          trackings.each do |tr|
            elem = []
            elem << tr.tblname
            elem << tr.rowid
            elem << tr.action
            json_data = tr.action == 'D' ? nil : pvsw.get_json_data_for(tr.tblname, tr.rowid)
            elem << json_data

            @data_to_queue << elem
          end

        end
      end

      def saves_data_as_prepared_data_rows
        @data_to_queue.each do |pdr|
          puts "saving data for: #{pdr[0]} #{pdr[1]} #{pdr[2]}"
          PreparedDataRow.create(
            tblname: pdr[0],
            rowid:   pdr[1],
            action:  pdr[2],
            data:    pdr[3]
          )
        end
      end

  end
end
