require 'spec_helper'

require_relative "#{ROOT_DIR}/lib/central/dispatcher"

module Central
  describe Dispatcher do
    let(:received_data_queue) { double("ReceivedDataQueue") }
    let(:applier)             { double('Applier').as_null_object }
    let(:dispatcher) { Dispatcher.new(received_data_queue, applier) }
    let(:stdout) { StringIO.new }
    
    describe "#process_filial_data" do
      before do
        @serialized = [[1, 'one', 23, 'I', 'json_data'], [2, 'one', 23, 'U', 'json_data2']]
        @ack_ids = [1, 2]
        @orig_stdout = $stdout
        $stdout = stdout
      end
      after { $stdout = @orig_stdout }
      
      it "saves as received and then asks Applier to process incoming data" do
        received_data_queue.should_receive(:save).with(@serialized).and_return(@ack_ids)
        applier.shoud_receive(:run)
        
        res = dispatcher.process_filial_data('filial', @serialized)
        res.should eq @ack_ids
      end
    end
  end
end
