require 'spec_helper'

module Filial
  describe TrackingsQueue do
    let(:tr1) {[1, 'oneTbl I', 12]}
    let(:tr2) {[2, 'twoTbl U', 23]}
    let(:not_parsed_trackings) {[tr1, tr2]}
    let(:trackings_queue) {TrackingsQueue.new}

    describe "#parse" do
      it "splits table name and action" do
        trackings_queue.send(:parse, tr2).should == ['twoTbl', 23, 'U']
      end
    end

    describe "#save_trackings!" do
      it "parses and saves trackings into Tracking model" do
        trackings_queue.save_trackings! not_parsed_trackings
        trackings_queue.trackings.size.should == 2
      end

    end

    describe "#simplifier" do
      [
        # spec_name  input for method         result
        ["I..U : U", ['I', 'U', 'D', 'I', 'U'], 'U'],
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
          trackings_queue.send(:simplifier, input).should == result
        end
      end

    end

    describe "#purge!" do

    end

  end
end
