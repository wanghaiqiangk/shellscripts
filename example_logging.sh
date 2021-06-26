#!/bin/sh

source ./logging/shell_logging.sh

LOG_LEVEL $LVL_WARN
INFO "Hello INFO"
DEBUG "Hello DEBUG"
WARN "Hello WARN"
FATAL "Hello FATAL"
INFO whitspace separated string

LOG_WHERE "./test.log"
LOG_LEVEL $LVL_DEBUG
INFO "Hello INFO"
DEBUG "Hello DEBUG"
WARN "Hello WARN"
FATAL "Hello FATAL"
INFO whitspace separated string
