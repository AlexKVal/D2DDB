SIDE = 'central'

require_relative 'lib/central/applier'

# debug
require_relative 'lib/client/prepared_data_queue'

module Central

  applier = Applier.new
  while true # here must be server, who will dispatch incoming connections
    # then it will save incoming data into #{filial_code}_prepared_data
    # and then run Applier (in same Thread was receiving data)

    # =========================================================
    # here is hackery-emulation receiving data from Filial
    # move data from client PreparedQueue to
    # =========================================================
    puts "incoming connection, receiving."
    received_data = []
    client_data_queue = Filial::PreparedDataQueue.new

    client_data_queue.data.each do |pdr|
      received_data << [pdr.id, pdr.tblname, pdr.rowid, pdr.action, pdr.data]
    end

    5.times{print '.'; sleep(1)}

    puts "\nreceived_data:"
    rdq = ReceivedDataQueue.new
    saved_ids = rdq.save(received_data)
    client_data_queue.remove_acknowledged_data!(saved_ids)
    p saved_ids
    # =========================================================
    # acknowledged_ids = @remote_object.process_filial_data(@filial_id, data_to_transmit)

    # now applier has to insert received data onto central dbase
    puts "\ngot incoming data for _filial_code_"
    puts "#{'='*60}"
    applier.run
    puts "#{'='*60}"
    sleep(3)

    # here should be the code preparing and sending data from Central to Filial db
    # puts "\prepare_tracked_data"
    # puts "#{'='*60}"
    # applier.prepare_tracked_data
    # #client.send_tracked_data
    # puts "#{'='*60}"
    # sleep(6)
  end

end
