#!/bin/bash


# start selenium server
nohup /opt/bin/start-selenium-standalone.sh &

#
# This script expects the standdard JMeter command parameters.
#

#  -e  Exit immediately if a command exits with a non-zero status.
# https://stackoverflow.com/a/19622569/8955356
set -e

# ref: https://stackoverflow.com/a/15517399/8955356
# -Xms<size>        set initial Java heap size

# freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`

# # -Xss<size>        set java thread stack size
# s=$(($freeMem/10*8)) 

# # -Xmx<size>        set maximum Java heap size
# x=$(($freeMem/10*8))

# # -Xmn<size>        sets the initial and maximum size (in bytes) of the heap for the young generation (nursery)
# n=$(($freeMem/10*2)) 
# export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

# echo "JVM_ARGS=${JVM_ARGS}"

echo "START Running Apache JMeter (worker)on `date`"

echo "$CMD args=$@" # pass arument to $@

# timestamp=$(date +%Y%m%d_%H%M%S)
INPUT_DATA=$@
INPUT_DATA_ARRAY=($INPUT_DATA)

# POD_IP=${INPUT_DATA_ARRAY[0]}
# SHARE_FOLDER=${INPUT_DATA_ARRAY[1]}

# echo "INPUT_DATA_ARRAY: ${INPUT_DATA_ARRAY}"
# echo "POD_IP: ${POD_IP}"
# echo "SHARE_FOLDER: ${SHARE_FOLDER}"

WORKER_ARGUMENT="-n -s \
  -Jserver.rmi.localport=50000 \
  -Dserver_port=1099 \
  -Djava.security.manager \
  -Djava.security.policy=${JMETER_BIN}/java.policy \
  -Djmeter.home=${JMETER_HOME} \
  -j worker_log.log"

# Keep entrypoint simple: we must pass the standard JMeter arguments
jmeter ${WORKER_ARGUMENT}
echo "END Running Jmeter on `date`"

