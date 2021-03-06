require 'spec_helper'

module Filial
  Track = Struct.new(:tblname, :rowid, :action)

  describe PreparedDataQueue do
    let(:pdq) {PreparedDataQueue.new}
    after(:each)  {PreparedDataRow.clear!}

    describe "#data_to_send" do
      it "serialize data to array" do
        [
          [1,  'oneTable', 23, 'I', 'json_data'],
          [23, 'twoTable', 44, 'I', 'json_data']
        ].each do |e|
          PreparedDataRow.create(id:    e[0], tblname: e[1],
                                 rowid: e[2], action:  e[3],
                                 data:  e[4])
        end
        pdq.data_to_send.should eq [[1, 'oneTable', 23, 'I', 'json_data'],[23, 'twoTable', 44, 'I', 'json_data']]
      end
    end

    describe "#remove_sent" do
      it "removes records with ids on the list" do
        [
          [1,   'oneTable', 23, 'I', 'json_data'],
          [23,  'twoTable', 44, 'I', 'json_data'],
          [45,  'oneTable', 23, 'U', 'json_data'],
          [246, 'twoTable', 44, 'U', 'json_data'],
          [556, 'twoTable', 44, 'U', 'json_data'],
        ].each do |e|
          PreparedDataRow.create(id:    e[0], tblname: e[1],
                                 rowid: e[2], action:  e[3],
                                 data:  e[4])
        end
        PreparedDataRow.all.size.should == 5

        received_ids = [1, 23, 45, 246]
        pdq.remove_sent(received_ids)
        PreparedDataRow.all.size.should == 1
        PreparedDataRow.first.id.should == 556
      end

      it "resets sequence for id field if empty" do
        [
          [1,  'oneTable', 23, 'I', 'json_data'],
          [23, 'twoTable', 44, 'I', 'json_data'],
          [45, 'oneTable', 23, 'U', 'json_data']
        ].each do |e|
          PreparedDataRow.create(id:    e[0], tblname: e[1],
                                 rowid: e[2], action:  e[3],
                                 data:  e[4])
        end
        PreparedDataRow.all.size.should == 3

        received_ids = [1, 23, 45]
        pdq.remove_sent(received_ids)
        PreparedDataRow.all.size.should == 0

        PreparedDataRow.create(tblname: 'tbl', rowid: 1, action: 'D', data: nil)
        PreparedDataRow.first.id.should == 1
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
        it "returns read data from pvsw in json format" do
          res = pdq.send(:get_data_for, @tracks)

          res.first[0].should == 'tableOne'
          res.first[1].should == 1
          res.first[2].should == 'I'
          JSON.parse(res.first[3]).should == {
            "ID"=>1, "string_prm"=>"Three Param",
            "integer_prm"=>214323, "short_prm"=>30000,
            "float_prm"=>2.5, "date_prm"=>"2011-12-17",
            "time_prm"=>"00:41:20", "bool_prm"=>0
          }
        end

        it "puts id-column name into data field if action is Delete" do
          res = pdq.send(:get_data_for, [Track.new('tableOne', 1, 'D')])

          res.first[0].should == 'tableOne'
          res.first[1].should == 1
          res.first[2].should == 'D'
          res.first[3].should == 'ID'
        end
      end

      describe "#saves_data_as_prepared_data_rows" do
        it "saves prepared data array to queue as PreparedDataRow" do
          pdq.data.size.should eq 0

          data_array = pdq.send(:get_data_for, @tracks)
          pdq.send(:saves_data_as_prepared_data_rows, data_array)

          pdq.data.size.should eq 1
        end
      end

    end
  end
end
