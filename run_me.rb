require_relative 'tracking_queue'
require_relative 'table_tracking'
require_relative 'tracked_data_rows'
require_relative 'prepared_data_queue'
require_relative 'exchanger'
require_relative 'client'

3.times do
  client = Client.new
  client.get_trackings!
  client.prepare_tracked_data
  client.send_tracked_data
end
