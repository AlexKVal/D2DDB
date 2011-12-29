require_relative 'config'
require_relative 'central/received_data_queue'

module Central
  class Applier
    def initialize(rdq = ReceivedDataQueue.new)
      @received_data_queue = rdq
    end

    def run
      received_rows = @received_data_queue.data
      
      received_rows.each do |row|
        case row.action
        when 'I'
        when 'U'
        when 'D'
        end
      end
      
      @received_data_queue.clear!
    end
  end
end
