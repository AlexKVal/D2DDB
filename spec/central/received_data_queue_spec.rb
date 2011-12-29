require 'spec_helper'

module Central
  describe ReceivedDataQueue do
    let(:rdq) {ReceivedDataQueue.new}

    before(:each) {ReceivedDataRow.clear!; rdq.clear_prepared_ids}
    after(:each)  {ReceivedDataRow.clear!; rdq.clear_prepared_ids}

    describe "#save" do
      it "adds incoming data onto queue" do
        rdq.data.size.should == 0

        rdq.save([[3, 'twoTable', 44, 'I', 'json_data']])
        rdq.data.size.should == 1

        incoming_data = [
          [1, 'oneTable', 23, 'I', 'json_data'],
          [23, 'twoTable', 44, 'I', 'json_data'],
          [45, 'oneTable', 23, 'U', 'json_data'],
          [246, 'twoTable', 44, 'U', 'json_data'],
          [556, 'twoTable', 44, 'U', 'json_data'],
        ]
        rdq.save(incoming_data)
        rdq.data.size.should == 6
      end
    end
  end
end
