require_relative 'models/tracking'

module Filial
  class TrackingsQueue
    def trackings
      Tracking.all
    end

    def save_trackings(not_parsed_trackings)
      not_parsed_trackings.each do |tr|
        tblname, rowid, action = parse tr
        return false unless Tracking.create(tblname: tblname, rowid: rowid, action: action)
      end
    end

    def purge!
      track_keys = Tracking.all(:fields => [:tblname, :rowid], :unique => true, :order => [:tblname.asc])

      new_trackings = []
      track_keys.each do |key|
        trackings_for_this_key = Tracking.all(tblname: key.tblname, rowid: key.rowid)

        actions_num  = trackings_for_this_key.count
        first_action = trackings_for_this_key.first.action
        last_action  = trackings_for_this_key.last.action

        if actions_num > 1
          result_action = simplifier(first_action, last_action)
        else
          result_action = first_action
        end
        #puts "#{first_action}..#{last_action} : #{result_action}"

        new_trackings << Tracking.new(
          tblname: key.tblname,
          rowid:   key.rowid,
          action:  result_action
        ) if result_action
      end

      # bulk update trackings table
      Tracking.clear!
      new_trackings.map(&:save)

      @trackings = Tracking.all
    end

    def clear!
      Tracking.clear!
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

      # for same Table and Row in it
      # I..U : I
      # I..D : -
      # I..I : I
      # U..U : U
      # U..D : D
      # U..I : U
      # D..U : U
      # D..D : D
      # D..I : U
      def simplifier(first, last)
        case first
        when 'I'
          last == 'D' ? nil : 'I'
        when 'U', 'D'
          last == 'D' ? 'D' : 'U'
        end
      end
  end
end
