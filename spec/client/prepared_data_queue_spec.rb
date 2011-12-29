require 'spec_helper'

module Filial
  Track = Struct.new(:tblname, :rowid, :action)

  describe PreparedDataQueue do
    let(:pdq) {PreparedDataQueue.new}

    describe "#remove_acknowledged_data!" do
      before(:each) {PreparedDataRow.clear!}
      after(:each)  {PreparedDataRow.clear!}

      it "removes records with ids on the list" do
        [
          [1, 'oneTable', 23, 'I', 'json_data'],
          [23, 'twoTable', 44, 'I', 'json_data'],
          [45, 'oneTable', 23, 'U', 'json_data'],
          [246, 'twoTable', 44, 'U', 'json_data'],
          [556, 'twoTable', 44, 'U', 'json_data'],
        ].each do |e|
          PreparedDataRow.create(id: e[0], tblname: e[1],
                                 rowid: e[2], action: e[3],
                                 data: e[4])
        end
        PreparedDataRow.all.size.should == 5

        acknowledged_ids = [1, 23, 45, 246]
        pdq.remove_acknowledged_data!(acknowledged_ids)
        PreparedDataRow.all.size.should == 1
        PreparedDataRow.first.id.should == 556
      end

    end

    describe "pvsw-database methods", :pvsw do
      before do
        @tracks = [Track.new('tableOne', 1, 'I')]
        Pvsw.do_some_sqls_no_result(
          "INSERT INTO tableOne
        (string_prm, integer_prm, short_prm, float_prm, date_prm, time_prm, bool_prm)
        VALUES('Three Param', 214323, 30000, 2.5, '17/12/2011','00:41:20', 0)")
      end
      after do
        Pvsw.do_sql_no_result("DELETE FROM tableOne")
        PreparedDataRow.clear!
        Tracking.clear!
      end

      describe "#queue_next_by" do
        it "saves data for trackings as preparedDataRows and clears trackings" do
          track_queue = TrackingsQueue.new
          track_queue.save_trackings([[1, 'tableOne I', 1]])
          track_queue.trackings.size.should == 1
          PreparedDataRow.all.size.should   == 0

          pdq.queue_next_by(track_queue)

          track_queue.trackings.size.should == 0
          PreparedDataRow.all.size.should   == 1
        end
      end

      describe "#get_data_for" do
        it "reads data from pvsw in json format" do
          pdq.send(:get_data_for, @tracks)
          pdq.data.first[0].should == 'tableOne'
          pdq.data.first[1].should == 1
          pdq.data.first[2].should == 'I'
          JSON.parse(pdq.data.first[3]).should == {"ID"=>1, "string_prm"=>"Three Param",
                                                   "integer_prm"=>214323, "short_prm"=>30000,
                                                   "float_prm"=>2.5, "date_prm"=>"2011-12-17",
                                                   "time_prm"=>"00:41:20", "bool_prm"=>0}
        end

        it "doesn't read any data from pvsw if action is Delete" do
          pdq.send(:get_data_for, [Track.new('tableOne', 1, 'D')])
          pdq.data.first[0].should == 'tableOne'
          pdq.data.first[1].should == 1
          pdq.data.first[2].should == 'D'
          pdq.data.first[3].should be_nil
        end
      end

    end
  end
end
