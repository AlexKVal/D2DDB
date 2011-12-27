require 'spec_helper'

module Filial
  describe TrackingsQueue do
    let(:tr1) {[1, 'oneTbl I', 12]}
    let(:tr2) {[2, 'twoTbl U', 23]}
    let(:trackings_queue) {TrackingsQueue.new}

    describe "no database methods" do

      describe "#parse" do
        it "splits table name and action" do
          trackings_queue.send(:parse, tr1).should == ['oneTbl', 12, 'I']
          trackings_queue.send(:parse, tr2).should == ['twoTbl', 23, 'U']
        end
      end

      describe "#simplifier" do
        [
          # spec_name  input for method         result
          ["I..U : U", ['I', 'U', 'D', 'I', 'U'], 'I'],
          ["I..D : -", ['I', 'U', 'D', 'I', 'D'], nil],
          ["I..I : I", ['I', 'U', 'U', 'D', 'I'], 'I'],
          ["U..U : U", ['U', 'U', 'D', 'I', 'U'], 'U'],
          ["U..D : D", ['U', 'U', 'D', 'I', 'D'], 'D'],
          ["U..I : U", ['U', 'U', 'U', 'D', 'I'], 'U'],
          ["D..U : U", ['D', 'I', 'D', 'I', 'U'], 'U'],
          ["D..D : D", ['D', 'I', 'D', 'I', 'D'], 'D'],
          ["D..I : U", ['D', 'I', 'U', 'U', 'I'], 'U'],
        ].each do |spec, input, result|
          it "#{spec}" do
            trackings_queue.send(:simplifier, input.first, input.last).should == result
          end
        end
      end

    end

    describe "database methods" do
      let(:not_parsed_trackings) {[tr1, tr2]}

      after(:each) do
        Tracking.clear!
      end

      describe "#save_trackings" do
        it "parses and saves trackings into Tracking model" do
          trackings_queue.save_trackings not_parsed_trackings
          trackings_queue.trackings.size.should == 2
        end
      end

      describe "#purge!" do
        before(:each) do
          @raw_trackings = []
          @raw_trackings << [1, 'oneTbl I', 12]
          @raw_trackings << [2, 'oneTbl U', 12]
          #
          @raw_trackings << [3, 'secTbl D', 212]
          @raw_trackings << [3, 'secTbl I', 212]
          @raw_trackings << [4, 'secTbl U', 212]
          #
          @raw_trackings << [5, 'oneTbl I', 33]
          @raw_trackings << [6, 'oneTbl U', 33]
          @raw_trackings << [7, 'oneTbl D', 33]
          @raw_trackings << [8, 'oneTbl I', 33]
          @raw_trackings << [9, 'oneTbl U', 33]
          #
          @raw_trackings << [10, 'secTbl I', 233]
          @raw_trackings << [11, 'secTbl D', 233]
          #
          @raw_trackings << [12, 'thirdTbl I', 1]
          #
          @raw_trackings << [13, 'thirdTbl U', 2]
          @raw_trackings << [14, 'thirdTbl U', 2]
          @raw_trackings << [15, 'thirdTbl U', 2]
        end

        it "uses simplifier over each distinct [table:rowid] tracking" do
          trackings_queue.save_trackings @raw_trackings
          #before
          trackings_queue.trackings.size.should == 16

          trackings_queue.purge!

          #after
          trs = trackings_queue.trackings
          trs.size.should == 5
          
          one_12 = trs.all(tblname: 'oneTbl', rowid: 12)
          one_12.size.should == 1
          one_12.first.action.should == 'I'
          
          one_33 = trs.all(tblname: 'oneTbl', rowid: 33)
          one_33.size.should == 1
          one_33.first.action.should == 'I'
          
          sec_212 = trs.all(tblname: 'secTbl', rowid: 212)
          sec_212.size.should == 1
          sec_212.first.action.should == 'U'
          
          sec_233 = trs.all(tblname: 'secTbl', rowid: 233)
          sec_233.size.should == 0
          
          third_1 = trs.all(tblname: 'thirdTbl', rowid: 1)
          third_1.size.should == 1
          third_1.first.action.should == 'I'
          
          third_2 = trs.all(tblname: 'thirdTbl', rowid: 2)
          third_2.size.should == 1
          third_2.first.action.should == 'U'
        end


      end
    end

  end
end
