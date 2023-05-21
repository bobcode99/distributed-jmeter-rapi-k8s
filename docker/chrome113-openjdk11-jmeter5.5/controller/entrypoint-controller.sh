#!/bin/bash

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
timestamp=$(date +%Y%m%d_%H%M%S)

echo "START Running Apache JMeter (controller) on `date`"
echo "START CONTROLLER on ${timestamp}"

# controller_ARGUMENT="-n -X \
#   -Djava.security.manager \
#   -Djava.security.policy=${JMETER_HOME}/bin/java.policy \
#   -Djmeter.home=${JMETER_HOME} \
#   -t ${TEST_PLAN_PATH}/${TEST_PLAN_NAME} \
#   -R ${workers_IP} \
#   -l ${TEST_PLAN_PATH}/client/result_${timestamp}.csv \
#   -j ${TEST_PLAN_PATH}/client/jmeter_${timestamp}.log \
#   -e -o ${TEST_PLAN_PATH}/client/html-report_${timestamp}"

# use for pod will not crash
tail -f /dev/null

# will not execute downside

# Keep entrypoint simple: we must pass the standard JMeter arguments
# jmeter ${controller_ARGUMENT}
# echo "END Running Jmeter on `date`"

