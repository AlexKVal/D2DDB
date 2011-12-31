require_relative "configuration"
require_relative "client/table_tracking"
require_relative "client/trackings_queue"
require_relative "client/prepared_data_queue"
require_relative "client/exchanger"
require 'drb'

module Filial
  class Client
    attr_accessor :remote_object

    def connect_to_server(server_uri)
      DRb.start_service
      @remote_object = DRbObject.new_with_uri server_uri
    end

    def initialize(fil_id,
                   tbl_tracking = TableTracking.new,
                   tr_queue     = TrackingsQueue.new,
                   prep_data_q  = PreparedDataQueue.new)
      @filial_id           = fil_id
      @table_tracking      = tbl_tracking
      @trackings_queue     = tr_queue
      @prepared_data_queue = prep_data_q
    end

    def get_trackings!
      if @table_tracking.poll
        not_parsed_trackings = @table_tracking.read_trackings
        @table_tracking.delete_read_trackings if @trackings_queue.save_trackings(not_parsed_trackings)
      end
    end

    def prepare_tracked_data
      @trackings_queue.purge!

      @prepared_data_queue.queue_next_by(@trackings_queue)
    end

    def send_tracked_data
      data_to_transmit = []
      @prepared_data_queue.data.each do |pdr|
        data_to_transmit << [pdr.id, pdr.tblname, pdr.rowid, pdr.action, pdr.data]
      end
      acknowledged_ids = @remote_object.process_filial_data(@filial_id, data_to_transmit)
      @prepared_data_queue.remove_acknowledged_data!(acknowledged_ids)
    end
  end
end
