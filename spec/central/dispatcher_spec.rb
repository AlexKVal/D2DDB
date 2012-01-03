require 'spec_helper'

require_relative "#{ROOT_DIR}/lib/central/dispatcher"

module Central
  describe Dispatcher do
    let(:received_data_queue) { double("ReceivedDataQueue") }
    let(:applier)             { double('Applier').as_null_object }
    let(:dispatcher) { Dispatcher.new(received_data_queue, applier) }

    describe "#receive_filial_data" do
      before do
        @serialized = [[1, 'one', 23, 'I', 'json_data'], [2, 'one', 23, 'U', 'json_data2']]
        @ack_ids = [1, 2]
      end

      it "saves as received and then asks Applier to process incoming data" do
        received_data_queue.should_receive(:save).with(@serialized)
        applier.shoud_receive(:run)

        res = dispatcher.receive_filial_data('filial', @serialized) {|a| 'ok'}
      end
    end
  end
end
