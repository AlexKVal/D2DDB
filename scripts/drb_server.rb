#!/usr/bin/env ruby -w
require 'drb'

URI = 'druby://:8080'

class One
  # Make dRuby send Logger instances as dRuby references,
  # not copies.
  include DRb::DRbUndumped
  def pt(val)
    puts "One: #{val}"
  end
end

FRONT_OBJECT = One.new

class Two
  def puts(val)
    puts "Two: #{val}"
  end
end

$SAFE = 1   # disable eval() and friends

# start up the DRb service
DRb.start_service(URI, FRONT_OBJECT)
puts DRb.uri

#trap("INT") { DRb.stop_service }

# wait for the DRb service to finish before exiting
DRb.thread.join
