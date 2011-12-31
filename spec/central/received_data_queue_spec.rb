require 'spec_helper'

module Central
  describe ReceivedDataQueue do
    let(:stdout) { StringIO.new }
    let(:rdq) {ReceivedDataQueue.new(stdout)}

    after(:each)  {ReceivedDataRow.clear!}

    describe "#save" do
      it "adds incoming data onto queue" do
        rdq.data.size.should == 0

        saved_ids = rdq.save([[3, 'twoTable', 44, 'I', 'json_data']])
        rdq.data.size.should == 1
        saved_ids.should == [3]

        incoming_data = [
          [1, 'oneTable', 23, 'I', 'json_data'],
          [23, 'twoTable', 44, 'I', 'json_data'],
          [45, 'oneTable', 23, 'U', 'json_data'],
          [246, 'twoTable', 44, 'U', 'json_data'],
          [556, 'twoTable', 44, 'U', 'json_data'],
        ]
        saved_ids = rdq.save(incoming_data)
        rdq.data.size.should == 6
        saved_ids.should == [1, 23, 45, 246, 556]
      end
    end

    describe "#clear!" do
      it "resets sequence for id field" do
        incoming_data = [
          [1, 'oneTable', 23, 'I', 'json_data'],
          [23, 'twoTable', 44, 'I', 'json_data'],
          [45, 'oneTable', 23, 'U', 'json_data']
        ]
        rdq.save(incoming_data)
        rdq.data.size.should eq 3

        rdq.clear!
        rdq.data.size.should eq 0

        rdq.save([[23, 'twoTable', 44, 'I', 'json_data']])
        rdq.data.first.id.should eq 1
      end
    end
  end
end
