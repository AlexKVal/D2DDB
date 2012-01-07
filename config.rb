# Filial-side
FILIAL_ID = 'Chab' # used for distinguish connections on server-side
SERVER_URI = 'druby://10.0.26.110:8083'
CALLBACK_URI = 'druby://10.0.35.230:20083'
SECONDS_WAIT_SERVER = 10
FILIAL_ALIAS = "D2Exp.NET"
MAIN_LOOP_PAUSE = 5

# Central-side
#CENTRAL_ALIAS = "CentrChab.NET" # alias for filial db on central server
#CENTRAL_PREFIX = 'chab' # prefix for tables
#LISTEN_URI = 'druby://:8083'

# DRb
$SAFE = 1   # disable eval() and friends

# Common
LOG_FILENAME = nil #'log.txt' # if nil then log to stdout
LOG_VERBOSE  = true
