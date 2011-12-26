require_relative 'tracking'

module Filial
  class TrackingsQueue
    attr_accessor :trackings

    def save_trackings!(not_parsed_trackings)
      not_parsed_trackings.each do |tr|
        tblname, rowid, action = parse tr
        Tracking.create(tblname: tblname, rowid: rowid, action: action)
      end
      @trackings = Tracking.all
    rescue
      return false
    end

    def purge!

    end

    private
      def parse(one_not_parsed_tracking)
        # [2, 'twoTbl U', 23] => ['twoTbl', 23, 'U']
        tbl_name, action = one_not_parsed_tracking[1].split
        result = []
        result << tbl_name
        result << one_not_parsed_tracking[2]
        result << action
      end

  end
end
