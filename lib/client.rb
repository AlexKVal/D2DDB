require_relative "client/config"
require_relative "client/table_tracking"
require_relative "client/trackings_queue"


module Filial
  class Client
    attr_accessor :table_tracking
    attr_accessor :trackings_queue
    attr_accessor :tracked_data_rows
    attr_accessor :prepared_data_queue
    attr_accessor :exchanger

    def initialize(tbl_tracking = TableTracking.new,
                   tr_queue     = TrackingsQueue.new,
                   tr_data_rows = TrackedDataRows.new,
                   prep_data_q  = PreparedDataQueue.new,
                   exch         = Exchanger.new)
      @table_tracking      = tbl_tracking
      @trackings_queue     = tr_queue
      @tracked_data_rows   = tr_data_rows
      @prepared_data_queue = prep_data_q
      @exchanger           = exch
    end

    def get_trackings!
      if table_tracking.poll
        not_parsed_trackings = table_tracking.read_trackings
        table_tracking.delete_read_trackings if trackings_queue.save_trackings!(not_parsed_trackings)
      end
    end

    def prepare_tracked_data
      trackings_queue.purge!
      tracked_data_rows.get(trackings_queue.trackings)
      prepared_data_queue.save! tracked_data_rows
    end

    def send_tracked_data
      exchanger.send prepared_data_queue
      prepared_data_queue.remove_acknowledged_data! exchanger.acknowledged_data
    end
  end
end
