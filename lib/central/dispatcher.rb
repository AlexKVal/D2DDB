require_relative 'applier'

module Central
  # Front object for DRb on server side
  class Dispatcher
    def initialize(rdq = ReceivedDataQueue.new,
                   appl = Applier.new(CENTRAL_ALIAS),
                   stdout = $stdout)
      @received_data_queue = rdq
      @applier = appl
      @stdout = stdout
    end

    def process_filial_data(filial_id, incoming_data)
      unless incoming_data.size == 0
        @stdout.puts "\nIncoming data: #{incoming_data.size} for filial: #{filial_id}"
        @stdout.puts "#{'='*60}"
        saved_ids = @received_data_queue.save(incoming_data)
        @stdout.puts "#{'='*60}"

        @stdout.puts "\nProcessing data for filial: #{filial_id}"
        @stdout.puts "#{'='*60}"
        @applier.run
        @stdout.puts "#{'='*60}"

        return saved_ids
      else
        @stdout.puts "\nEmpty incoming data from filial: #{filial_id}"
        @stdout.puts "#{'='*60}"

        return []
      end
    end
  end
end
