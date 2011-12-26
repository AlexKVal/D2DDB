require 'spec_helper'

module Filial
  describe TableTracking, :pvsw do
    let(:table_tracking) {TableTracking.new}

    describe "#poll" do
      describe "TableTracking is empty" do
        it "returns false" do
          table_tracking.poll.should be_false
        end
      end

      describe "TableTracking has one row" do
        before {Pvsw.do_sql_no_result("INSERT INTO urDataCh (tblOper, rowWithID) VALUES('table I', 23)")}

        it "returns true" do
          table_tracking.poll.should be_true
        end

        after(:each) {Pvsw.do_sql_no_result("DELETE FROM urDataCh")}
      end
    end

    describe "#read_trackings" do
      before do
        Pvsw.do_some_sqls_no_result(
        "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('oneTbl I', 12)",
        "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('twoTbl U', 23)")
      end

      it "returns values in arrays and saves them in @trackings" do
        trackings = table_tracking.read_trackings
        trackings.size.should == 2
        trackings.should include [1, 'oneTbl I', 12]
        trackings.should include [2, 'twoTbl U', 23]

        table_tracking.trackings.should == trackings
      end

      it "returns values in array ordered by ID" do
        Pvsw.do_some_sqls_no_result(
          "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('Three D', 214)",
          "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('oneTbl I', 12)",
          "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('twoTbl U', 23)")
        trackings = table_tracking.read_trackings
        trackings.size.should == 5
        trackings[0].should == [1, 'oneTbl I', 12]
        trackings[1].should == [2, 'twoTbl U', 23]
        trackings[2].should == [3, 'Three D', 214]
        trackings[3].should == [4, 'oneTbl I', 12]
        trackings[4].should == [5, 'twoTbl U', 23]

        table_tracking.trackings.should == trackings
      end

      after(:each) {Pvsw.do_sql_no_result("DELETE FROM urDataCh")}
    end

    describe "#delete_read_trackings" do
      before do
        Pvsw.do_some_sqls_no_result(
        "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('oneTbl I', 12)",
        "INSERT INTO urDataCh (tblOper, rowWithID) VALUES('twoTbl U', 23)")
      end

      it "deletes only previous read rows" do
        trackings = table_tracking.read_trackings
        trackings.size.should == 2

        Pvsw.do_sql_no_result("INSERT INTO urDataCh (tblOper, rowWithID) VALUES('Three D', 214)")
        table_tracking.delete_read_trackings
        table_tracking.trackings.should be_nil

        trackings = table_tracking.read_trackings
        trackings.size.should == 1
        trackings.should include [3, 'Three D', 214]

        table_tracking.trackings.should == trackings
      end

      after(:each) {Pvsw.do_sql_no_result("DELETE FROM urDataCh")}
    end

  end
end
