# Filial-side
FILIAL_ID = 'Chab' # used for distinguish connections on server-side
SERVER_URI = 'druby://localhost:8083'
SECONDS_WAIT_SERVER = 2
FILIAL_ALIAS = "D2Main.NET"
MAIN_LOOP_PAUSE = 3

# Central-side
CENTRAL_ALIAS = "CentrChab.NET" # alias for filial db on central server
CENTRAL_PREFIX = 'chab' # prefix for tables
LISTEN_URI = 'druby://:8083'

# DRb
$SAFE = 1   # disable eval() and friends

# Common
LOG_FILENAME = nil #'_log.txt' # if nil then log to stdout
LOG_VERBOSE  = true
