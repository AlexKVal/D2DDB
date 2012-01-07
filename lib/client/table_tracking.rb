require_relative '../shared/pvsw'

module Filial
  class TableTracking

    attr_accessor :trackings

    def poll
      res = Pvsw.do_sql_single_result("SELECT COUNT(*) FROM urDataCh")
      LOG.debug "TableTracking.poll res=#{res}"
      res > 0
    end

    def read_trackings
      LOG.debug "TableTracking.read_trackings"

      Pvsw.do_sql_multiple_results("SELECT * FROM urDataCh ORDER BY ID") do |stmt|
        @trackings = stmt.fetch_all
      end

      @trackings
    end

    def delete_read_trackings
      LOG.debug "TableTracking.delete_read_trackings"

      return unless @trackings && @trackings.size > 0
      # may be refactor this to use DataMapper methods. not sure.
      read_ids = @trackings.inject([]) {|ids, row| ids << row[0]}

      while read_ids.size > 0 do
        part_ids = read_ids[0..9]
        part_ids.size.times { read_ids.shift }

        sql = "DELETE FROM urDataCh WHERE ID IN(#{part_ids.join(', ')})"
        LOG.debug "sql: #{sql}"
        Pvsw.do_sql_single_result(sql)
      end
      @trackings = nil
    end
  end
end