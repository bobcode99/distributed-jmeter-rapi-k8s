#!/bin/bash
set -f  # avoid globbing (expansion of *).
start=`date +%s`

export TIME_STAMP_FOR_JMETERK8S=$(date +%Y%m%d_%H%M%S)

working_dir="`pwd`"

jmx="$1"
RAPI_TESTCASE="$2"
NAMESPACE_NAME="$3"
HELM_NAME="$4"
HELM_CHART_PATH="$5"
HELM_VALUES_PATH="$6"
NUM_TOTAL_WORKER_CONTROLLER="$7"
KUBE_CONFIG_PATH="/home/selab/.kube/config"

if [ "$jmx" == "" -o "$RAPI_TESTCASE" == "" -o "$NAMESPACE_NAME" == "" -o "$HELM_NAME" == "" -o "$HELM_CHART_PATH" == "" -o "$NUM_TOTAL_WORKER_CONTROLLER" == "" ];then
   echo "pleas input again"
   exit
fi

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

echo "working_dir: ${working_dir}"
echo "test path + test name: ${jmx}"
test_plan_name=${jmx##*/}
echo "test_plan_name: ${test_plan_name}"
echo "Rapi testcase path: ${RAPI_TESTCASE}"
echo "NAMESPACE_NAME : ${NAMESPACE_NAME}"
echo "HELM_NAME: ${HELM_NAME}"
echo "HELM_CHART_PATH: ${HELM_CHART_PATH}"
echo "NUM_TOTAL_WORKER_CONTROLLER: ${NUM_TOTAL_WORKER_CONTROLLER}"
echo "KUBE_CONFIG_PATH: ${KUBE_CONFIG_PATH}"

# ====================================================================================================================================================================
kubectl --kubeconfig ${KUBE_CONFIG_PATH} create namespace ${NAMESPACE_NAME}
helm --kubeconfig ${KUBE_CONFIG_PATH} install --namespace ${NAMESPACE_NAME} ${HELM_NAME} ${HELM_CHART_PATH} --set worker_replica=${NUM_TOTAL_WORKER_CONTROLLER} --values ${HELM_VALUES_PATH}

# check pods create done or not
NUM_OF_PODS_RUNNING=0
while [ ${NUM_OF_PODS_RUNNING} -lt $(( ${NUM_TOTAL_WORKER_CONTROLLER} + 1)) ]
do
    PODS_STATUS=$(kubectl --kubeconfig ${KUBE_CONFIG_PATH} get pods --namespace=${NAMESPACE_NAME} -o jsonpath='{.items[*].status.phase}')
    NUM_OF_PODS_RUNNING="`grep -o 'Running' <<<"$PODS_STATUS" | grep -c .`"
    echo "pod status: ${PODS_STATUS}"
    echo "NUM_OF_PODS_RUNNING: ${NUM_OF_PODS_RUNNING}"
    sleep 1
done
# ====================================================================================================================================================================

# ================================================================================================================================
# get variable
CONTROLLER_NAME=$(kubectl --kubeconfig ${KUBE_CONFIG_PATH} get pods --namespace=${NAMESPACE_NAME} -l jmeter_mode=controller -o jsonpath='{.items[*].metadata.name}')
STRING_WORKER_NAME=$(kubectl --kubeconfig ${KUBE_CONFIG_PATH} get pods --namespace=${NAMESPACE_NAME} -l jmeter_mode=worker -o=jsonpath='{.items..metadata.name}' | tr ' ' ',')
ARRAY_STRING_WORKER_NAME=(${STRING_WORKER_NAME//,/ })
WORKER_IPS=$(kubectl --kubeconfig ${KUBE_CONFIG_PATH} get pods --namespace=${NAMESPACE_NAME} -l jmeter_mode=worker -o jsonpath='{.items[*].status.podIP}' | tr ' ' ',')
# ================================================================================================================================
echo "CONTROLLER_NAME: ${CONTROLLER_NAME}"
echo "STRING_WORKER_NAME: ${STRING_WORKER_NAME}"
echo "WORKER_IPS: ${WORKER_IPS}"

echo "start copy jmeter testcase to controller node"
echo "start copy ${test_plan_name} to ${CONTROLLER_NAME}"

kubectl --kubeconfig ${KUBE_CONFIG_PATH} cp ${jmx} ${CONTROLLER_NAME}:/mnt/${test_plan_name} --namespace=${NAMESPACE_NAME}
echo "done copy jmeter testcase to controller node"

echo "start copy rapi-test-case"
for i in "${!ARRAY_STRING_WORKER_NAME[@]}"
do
    echo "doing copy rapi-test-case to ${ARRAY_STRING_WORKER_NAME[i]}"
    kubectl --kubeconfig ${KUBE_CONFIG_PATH} cp ${RAPI_TESTCASE} ${ARRAY_STRING_WORKER_NAME[i]}:/mnt/testSuite.json --namespace=${NAMESPACE_NAME}
done

echo "start execute test";
# start testing 
kubectl --kubeconfig ${KUBE_CONFIG_PATH} exec --namespace=${NAMESPACE_NAME} \
    -it $CONTROLLER_NAME -- jmeter -n -t /mnt/${test_plan_name} \
    -R $WORKER_IPS \
    -l result.csv \
    -j jmeter-log.log
    #\
    #-e -o report-html

echo "done test"

echo "start copy logs, report, ..."

# ================================================================================================================================
# ./copy-controller-logs-files.sh
echo "start copy controller files!"
CONTROLLER_RESULT_FOLDER="controller-things-${TIME_STAMP_FOR_JMETERK8S}"

kubectl --kubeconfig ${KUBE_CONFIG_PATH} cp ${CONTROLLER_NAME}:result.csv ./${CONTROLLER_RESULT_FOLDER}/result.csv --namespace=${NAMESPACE_NAME}
kubectl --kubeconfig ${KUBE_CONFIG_PATH} cp ${CONTROLLER_NAME}:jmeter-log.log ./${CONTROLLER_RESULT_FOLDER}/jmeter-log.log --namespace=${NAMESPACE_NAME}
# kubectl --kubeconfig ${KUBE_CONFIG_PATH} cp ${CONTROLLER_NAME}:report-html ./${CONTROLLER_RESULT_FOLDER}/report-html --namespace=${NAMESPACE_NAME}

echo "done copy controller files!"
# ================================================================================================================================


# ================================================================================================================================
# ./copy-worker-logs-files.sh
echo "start copy worker logs!"
WORKERS_RESULT_FOLDER="worker-log-${TIME_STAMP_FOR_JMETERK8S}"

for i in "${!ARRAY_STRING_WORKER_NAME[@]}"
do
    echo "doing copy worker log ${ARRAY_STRING_WORKER_NAME[i]}"
    kubectl --kubeconfig ${KUBE_CONFIG_PATH} cp ${ARRAY_STRING_WORKER_NAME[i]}:worker_log.log ./${WORKERS_RESULT_FOLDER}/${ARRAY_STRING_WORKER_NAME[i]}.log --namespace=${NAMESPACE_NAME}
done
echo "done copy worker logs!"
# ================================================================================================================================

echo "all test, copy done!!"
end=`date +%s`
runtime=$((end-start))

# echo "Start delete helm chart"
# helm --kubeconfig ${KUBE_CONFIG_PATH} uninstall --namespace ${NAMESPACE_NAME} ${HELM_NAME}
# echo "Done delete helm chart"

# # delete namespace
# echo "Start delete namespace"
# kubectl --kubeconfig ${KUBE_CONFIG_PATH} delete namespace ${NAMESPACE_NAME}
# echo "Finish delete namespace"
echo "Total time: ${runtime}"
