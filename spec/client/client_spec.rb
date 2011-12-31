require 'spec_helper'

module Filial
  describe Client do
    let(:trackings_queue)     { double("TrackingsQueue").as_null_object }
    let(:table_tracking)      { double("TableTracking").as_null_object }
    let(:prepared_data_queue) { double("PreparedDataQueue") }
    let(:remote_double)       { double('proxy').as_null_object }
    let(:client) { Client.new('filial', TESTDB_ALIAS, table_tracking, trackings_queue, prepared_data_queue) }

    describe "#get_trackings!" do
      describe "when there are no trackings" do
        it "only polls the TableTracking" do
          table_tracking.should_receive(:poll)

          client.get_trackings!
        end
      end

      describe "when there are some trackings" do
        it "polls, reads and deletes trackings if queue them success" do
          table_tracking.should_receive(:poll).ordered.and_return([:some, :trackings])
          table_tracking.should_receive(:read_trackings).ordered
          table_tracking.should_receive(:delete_read_trackings).ordered
          trackings_queue.should_receive(:save_trackings).and_return(true)

          client.get_trackings!
        end

        it "polls and reads only trackings if queue them fails" do
          table_tracking.should_receive(:poll).ordered.and_return([:some, :trackings])
          table_tracking.should_receive(:read_trackings).ordered
          trackings_queue.should_receive(:save_trackings).and_return(false)

          client.get_trackings!
        end
      end
    end

    describe "#prepare_tracked_data" do
      it "queue data from pvsw by trackings list" do
        prepared_data_queue.should_receive(:queue_next_by).with(trackings_queue)

        client.prepare_tracked_data
      end
    end

    describe "#send_tracked_data" do
      Pdr = Struct.new :id, :tblname, :rowid, :action, :data

      before do
        @data_rows = []
        @data_rows << Pdr.new(1, 'one', 23, 'I', 'json_data')
        @data_rows << Pdr.new(2, 'one', 23, 'U', 'json_data2')
        @serialized = [[1, 'one', 23, 'I', 'json_data'], [2, 'one', 23, 'U', 'json_data2']]
        @ack_ids = [1, 2]
      end

      it "serialize prepared data, put them to remote and process ack_ids" do
        prepared_data_queue.should_receive(:data).and_return(@data_rows)
        remote_double.should_receive(:process_filial_data).with('filial', @serialized).and_return(@ack_ids)
        prepared_data_queue.should_receive(:remove_acknowledged_data!).with(@ack_ids)

        client.remote_object = remote_double
        client.send_tracked_data
      end

      it "waits for the server is online infinitely" do
        prepared_data_queue.should_receive(:data).and_return(@data_rows)
        prepared_data_queue.should_receive(:remove_acknowledged_data!)

        remote_double.stub(:process_filial_data) { raise "no connection" }
        client.infinite = false
        client.seconds_wait = 0

        client.remote_object = remote_double
        client.send_tracked_data
      end
    end

  end
end
