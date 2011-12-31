#!/usr/bin/env ruby -w
require 'drb'

SERVER_URI = 'druby://localhost:8080'

# Start a local DRbServer to handle callbacks.
#
# Not necessary for this small example, but will be required
# as soon as we pass a non-marshallable object as an argument
# to a dRuby call.
DRb.start_service

# attach to the DRb server via a URI given on the command line
one = DRbObject.new_with_uri SERVER_URI

one.puts ARGV.shift
