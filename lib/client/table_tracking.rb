require_relative '../shared/pvsw'

module Filial
  class TableTracking

    attr_accessor :trackings

    def poll
      res = Pvsw.do_sql_single_result("SELECT COUNT(*) FROM urDataCh")
      res > 0
    end

    def read_trackings
      Pvsw.do_sql_multiple_results("SELECT * FROM urDataCh") do |stmt|
        @trackings = stmt.fetch_all
      end
      @trackings
    end

    def delete_read_trackings
      return unless @trackings && @trackings.size > 0

      read_ids = @trackings.inject([]) {|ids, row| ids << row[0]}.join(', ')
      Pvsw.do_sql_single_result("DELETE FROM urDataCh WHERE ID IN(#{read_ids})")
      @trackings = nil
    end
  end
end