require_relative 'lib/applier'

module Central

  applier = Applier.new
  while true # here must be server, who will dispatch incoming connections
    # then it will save incoming data into #{filial_code}_prepared_data
    # and then run Applier (in same Thread was receiving data)

    # here is hackery-emulation receiving data from Filial
    # move data from client PreparedQueue to
    # =========================================================


    puts "\ngot incoming data for _filial_code_"
    puts "#{'='*60}"
    applier.get_trackings!
    puts "#{'='*60}"
    sleep(3)


    puts "\prepare_tracked_data"
    puts "#{'='*60}"
    applier.prepare_tracked_data
    #client.send_tracked_data
    puts "#{'='*60}"
    sleep(6)
  end

end
