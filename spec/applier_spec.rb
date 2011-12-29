require 'spec_helper'

module Central
  describe Applier do
    let(:applier) {Applier.new}

    describe "#names_values_for_insert_from" do
      it "quotes column names" do
        json_data = '{"col1":1,"col2":2}'
        names, values = applier.send(:names_values_for_insert_from, json_data)
        names.should eq %w('col1' 'col2')
      end

      it "quotes string values" do
        json_data = '{"string1":"val1","string2":"val2"}'
        names, values = applier.send(:names_values_for_insert_from, json_data)
        values.should eq %w('val1' 'val2')
      end

      it "quotes Date and Time values" do
        json_data = '{"date":"2011-11-12","time":"00:12:01"}'
        names, values = applier.send(:names_values_for_insert_from, json_data)
        values.should eq %w('2011-11-12' '00:12:01')
      end

      it "doesn't quotes integer (and logical) values" do
        json_data = '{"integer":123,"logical":1}'
        names, values = applier.send(:names_values_for_insert_from, json_data)
        values.should eq [123, 1]
      end
    end

    describe "#columns_for_insert" do
      it "compilates a value part of Insert command from json_data" do
        json_data = '{"str":"strval","int":2,"date":"11/12/2011","time":"00:12:00","bool":0}'
        res = applier.send(:columns_for_insert, json_data)
        res.should eq "('str', 'int', 'date', 'time', 'bool') VALUES ('strval', 2, '11/12/2011', '00:12:00', 0)"
      end
    end

    describe "#columns_for_update" do
      it "quotes string values" do
        json_data = '{"PersID":23,"str":"strval"}'
        res = applier.send(:columns_for_update, json_data)
        res.should eq "SET str = 'strval'"
      end

      it "doesn't quotes integer (and logical) values" do
        json_data = '{"PersID":23,"int":2}'
        res = applier.send(:columns_for_update, json_data)
        res.should eq "SET int = 2"
      end

      it "compilates a value part of Update command w/o ID column" do
        json_data = '{"PersID":23,"str":"strval","int":2,"date":"11/12/2011","time":"00:12:00","bool":0}'
        res = applier.send(:columns_for_update, json_data)
        res.should eq "SET str = 'strval', SET int = 2, SET date = '11/12/2011', SET time = '00:12:00', SET bool = 0"
      end
    end

    describe "#run", :pvsw do
      after(:each) do
        ReceivedDataRow.clear!
        Pvsw.do_sql_no_result("DELETE FROM tableTwo")
      end

      def pvsw_table_two_size
        Pvsw.do_sql_single_result("SELECT COUNT(*) FROM tableTwo")
      end

      xit "runs sql commands from the queue and then clean it" do
        pvsw_table_two_size.should eq 0

        # Insert
        ReceivedDataRow.create!(
          tblname: 'tableTwo', rowid: 23, action: 'I',
        data: '{"ID":23,"string_prm":"value","integer_prm":123,"date_prm":"2011-12-12"}')
        applier.run
        pvsw_table_two_size.should eq 1

        # Update
        ReceivedDataRow.create!(
          tblname: 'tableTwo', rowid: 23, action: 'U',
        data: '{"ID":23,"string_prm":"me me","integer_prm":321,"date_prm":"2011-1-1"}')
        applier.run
        pvsw_table_two_size.should eq 1

        # Delete
        ReceivedDataRow.create!(tblname: 'tableTwo', rowid: 23, action: 'D', data: nil)
        applier.run
        pvsw_table_two_size.should eq 0
      end

      it "cleans the queue after job done" do
        ReceivedDataRow.create!(
          tblname: 'tableTwo', rowid: 23, action: 'I',
        data: '{"ID":23,"string_prm":"value","integer_prm":123,"date_prm":"2011-12-12"}')
        ReceivedDataRow.all.size.should eq 1
        applier.run
        ReceivedDataRow.all.size.should eq 0
      end
    end
  end
end
