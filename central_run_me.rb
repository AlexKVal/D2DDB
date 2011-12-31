SIDE = 'central'

require_relative 'lib/central/dispatcher'
require 'drb'

module Central

  DRb.start_service(LISTEN_URI, Dispatcher.new)
  puts "Now listening: #{DRb.uri}"
  DRb.thread.join

end
