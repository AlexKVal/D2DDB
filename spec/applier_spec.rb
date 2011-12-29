require 'spec_helper'

module Central
  describe Applier do
    let(:applier) {Applier.new}

    describe "#run", :pvsw do
      after(:each) do
        ReceivedDataRow.clear!
        Pvsw.do_sql_no_result("DELETE FROM tableTwo")
      end

      def pvsw_table_two_size
        Pvsw.do_sql_single_result("SELECT COUNT(*) FROM tableTwo")
      end

      it "runs sql commands with received data" do
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
    end
  end
end
#string_prm integer_prm date_prm
