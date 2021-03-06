require_relative "../configuration"
require_relative "table_tracking"
require_relative "trackings_queue"
require_relative "prepared_data_queue"
require 'drb'

module Filial
  class Client
    attr_accessor :remote_object
    attr_accessor :infinite
    attr_accessor :seconds_wait

    def setup_remote_object(server_uri)
      LOG.debug "Client.setup_remote_object server_uri=#{server_uri}"

      DRb.start_service(CALLBACK_URI)
      LOG.debug "DRb.start_service on uri: #{DRb.uri}"

      @remote_object = DRbObject.new_with_uri server_uri
    end

    def initialize(fil_id, pvsw_alias,
                   tbl_tracking = TableTracking.new,
                   tr_queue     = TrackingsQueue.new,
                   prep_data_q  = PreparedDataQueue.new)
      @filial_id           = fil_id
      @table_tracking      = tbl_tracking
      @trackings_queue     = tr_queue
      @prepared_data_queue = prep_data_q

      LOG.debug "Client.new pvsw_alias=#{pvsw_alias}"
      Pvsw.odbc_alias = pvsw_alias

      @infinite = true
      @seconds_wait = 10
    end

    def get_trackings!
      LOG.debug "Client.get_trackings!"

      poll_res = @table_tracking.poll
      if poll_res
        not_parsed_trackings = @table_tracking.read_trackings
        @table_tracking.delete_read_trackings if @trackings_queue.save_trackings(not_parsed_trackings)
      end
      poll_res
    end

    def prepare_tracked_data
      LOG.debug "Client.prepare_tracked_data"

      @trackings_queue.purge!

      @prepared_data_queue.queue_next_by(@trackings_queue)
    end

    def send_tracked_data
      LOG.info "Client.send_tracked_data"

      data_to_send = @prepared_data_queue.data_to_send

      begin
        LOG.debug "Client begin: remote_object.receive_filial_data"
        @remote_object.receive_filial_data(@filial_id, data_to_send) do |received_ids|

          @prepared_data_queue.remove_sent(received_ids)

          LOG.debug "in block: return to server 'ok'"
          'ok' # answer to server
        end
        LOG.debug "break"
        break
      rescue
        LOG.info "!==> rescue: #{$!}. Sleep #{@seconds_wait}"
        sleep @seconds_wait
      end while @infinite

      LOG.info "== The end of sending data."
    end
  end
end
