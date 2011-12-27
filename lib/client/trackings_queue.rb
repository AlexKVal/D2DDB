require_relative 'tracking'

module Filial
  class TrackingsQueue
    attr_accessor :trackings

    def save_trackings(not_parsed_trackings)
      not_parsed_trackings.each do |tr|
        tblname, rowid, action = parse tr
        return false unless Tracking.create(tblname: tblname, rowid: rowid, action: action)
      end
      @trackings = Tracking.all
    end

    def purge!
      track_keys = Tracking.all(:fields => [:tblname, :rowid], :unique => true, :order => [:tblname.asc])

      new_trackings = []
      track_keys.each do |key|
        first_action = Tracking.all(tblname: key.tblname, rowid: key.rowid).first.action
        last_action  = Tracking.all(tblname: key.tblname, rowid: key.rowid).last.action

        result_action = simplifier(first_action, last_action)
        #puts "#{first_action}..#{last_action} : #{result_action}"
        
        new_trackings << Tracking.new(
                          tblname: key.tblname, 
                          rowid:   key.rowid, 
                          action:  result_action) if result_action
      end

      # bulk update trackings table
      Tracking.clear!
      new_trackings.map(&:save)

      @trackings = Tracking.all
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
