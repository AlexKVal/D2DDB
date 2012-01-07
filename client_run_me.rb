SIDE = 'filial'

require_relative 'lib/client/client'

module Filial

  client = Client.new(FILIAL_ID, FILIAL_ALIAS)
  client.setup_remote_object(SERVER_URI)
  client.seconds_wait = SECONDS_WAIT_SERVER

  while true
    LOG.debug "==> Main Loop <=="

    res = client.get_trackings!
    #if res
      LOG.info "==> got trackings"

      client.prepare_tracked_data

      client.send_tracked_data
    #end

    LOG.debug "sleep for #{MAIN_LOOP_PAUSE}"
    sleep MAIN_LOOP_PAUSE
  end

end
