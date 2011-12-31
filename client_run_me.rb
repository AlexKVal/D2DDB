SIDE = 'filial'

require_relative 'lib/client'

module Filial

  client = Client.new
  while true
    puts "\nget_trackings!"
    puts "#{'='*60}"
    client.get_trackings!
    puts "#{'='*60}"

    puts "\prepare_tracked_data"
    puts "#{'='*60}"
    client.prepare_tracked_data
    puts "#{'='*60}"
    
    sleep(3)
    
    puts "\prepare_tracked_data"
    puts "#{'='*60}"
    client.send_tracked_data
    puts "#{'='*60}"
    sleep(6)
  end

end
