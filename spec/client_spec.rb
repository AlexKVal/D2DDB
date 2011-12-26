require 'spec_helper'

module Filial
  describe Client do
    let(:trackings_queue)     { double("TrackingsQueue").as_null_object }
    let(:table_tracking)      { double("TableTracking").as_null_object }
    let(:tracked_data_rows)   { double("TrackedDataRows") }
    let(:prepared_data_queue) { double("PreparedDataQueue") }
    let(:exchanger)           { double("Exchanger").as_null_object }
    let(:client) { Client.new(table_tracking, trackings_queue,
                              tracked_data_rows, prepared_data_queue, exchanger) }

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
          trackings_queue.should_receive(:save_trackings!).and_return(true)

          client.get_trackings!
        end

        it "polls and reads only trackings if queue them fails" do
          table_tracking.should_receive(:poll).ordered.and_return([:some, :trackings])
          table_tracking.should_receive(:read_trackings).ordered
          trackings_queue.should_receive(:save_trackings!).and_return(false)

          client.get_trackings!
        end
      end
    end

    describe "#prepare_tracked_data" do
      it "asks the TrackedDataRows to get data belonges to trackings" do
        tracked_data = double("tracked_data")
        trackings_queue.should_receive(:trackings).and_return(tracked_data)
        tracked_data_rows.should_receive(:get).with(tracked_data)
        prepared_data_queue.should_receive(:save!).with(tracked_data_rows)

        client.prepare_tracked_data
      end
    end
    
    describe "#send_tracked_data" do
      it "asks the Exchanger to send prepared data" do
        data = double("data")
        exchanger.should_receive(:send).ordered.with(prepared_data_queue)
        exchanger.should_receive(:acknowledged_data).ordered.and_return(data)
        prepared_data_queue.should_receive(:remove_acknowledged_data!).with(data)
        client.send_tracked_data
      end
    end

  end
end
