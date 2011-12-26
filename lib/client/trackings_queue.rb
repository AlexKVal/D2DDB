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

    # U+ : U - it's done by SQL server by GROUP BY
    # IU : I
    # I[U]D : nothing
    # UD : D
    # D[U]I : U
    #
    # [ combo (IUD)I : I  |  (IUD)(IU) : I  |  U(DI) : U  |  (DI)U : U ]
    #
    # removes all previous Updates if last is Update => Update (by GROUP BY)
    # removes all next Updates if no Delete and first is Insert => Insert
    # removes all if first Insert and last Delete
    # removes previous Updates if no Inserts and last is Delete => Delete
    # removes Delete (and Updates if in the middle) if last is Insert => Update
    # =========================================================================
    # all above simpler see simplifier()
    def purge!

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
      # I..U : U
      # I..D : -
      # I..I : I
      # U..U : U
      # U..D : D
      # U..I : U
      # D..U : U
      # D..D : D
      # D..I : U
      def simplifier(ordered_actions_list)
        last = ordered_actions_list.last
        case ordered_actions_list.first
        when 'I'
          last == 'D' ? nil : last
        when 'U', 'D'
          last == 'D' ? 'D' : 'U'
        end
      end
  end
end
