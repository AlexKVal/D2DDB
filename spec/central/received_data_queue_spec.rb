require 'spec_helper'

module Central
  describe ReceivedDataQueue do
    let(:rdq) {ReceivedDataQueue.new}
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
    
    describe "clear.." do
      # it "resets sequence for id field if empty" do
      #   [
      #     [1, 'oneTable', 23, 'I', 'json_data'],
      #     [23, 'twoTable', 44, 'I', 'json_data'],
      #     [45, 'oneTable', 23, 'U', 'json_data']
      #   ].each do |e|
      #     PreparedDataRow.create(id: e[0], tblname: e[1],
      #                            rowid: e[2], action: e[3],
      #                            data: e[4])
      #   end
      #   PreparedDataRow.all.size.should == 3
      # 
      #   acknowledged_ids = [1, 23, 45]
      #   pdq.remove_acknowledged_data!(acknowledged_ids)
      #   PreparedDataRow.all.size.should == 0
      #   
      #   PreparedDataRow.create(tblname: 'tbl', rowid: 1, action: 'D', data: nil)
      #   PreparedDataRow.first.id.should == 1
      # end
      
    end
  end
end
