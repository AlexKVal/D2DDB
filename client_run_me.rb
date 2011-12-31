SIDE = 'filial'

require_relative 'lib/client/client'

module Filial

  client = Client.new(FILIAL_ID, FILIAL_ALIAS)
  client.setup_remote_object(SERVER_URI)
  while true
    puts "\nget_trackings!"
    puts "#{'='*60}"
    client.get_trackings!
    puts "#{'='*60}"

    puts "\nprepare_tracked_data"
    puts "#{'='*60}"
    client.prepare_tracked_data
    puts "#{'='*60}"

    sleep 3

    puts "\nsend_tracked_data"
    puts "#{'='*60}"
    client.seconds_wait = SECONDS_WAIT
    client.send_tracked_data
    puts "#{'='*60}"
    sleep 6
  end

end
