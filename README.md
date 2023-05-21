# distributed-jmeter-rapi-k8s

Apache JMeter distributed testing with Rapi.

```
export DIS_JMETER_PROJ_PATH=/home/selab/jmeter-proj-use/distributed-jmeter-rapi-k8s

./script/start-test-rapi.sh \
$DIS_JMETER_PROJ_PATH/jmeter-test-plan/rapiTestPlanUseTCForK8s-manythread.jmx \
$DIS_JMETER_PROJ_PATH/rapi-test-suites/wordpress-a-b-testing-8020-suite-recordb20-noscroll.json \
jmeter-rapi--wordp-a80b20useb20--t5w10-lim-100-1 \
helm--wau--t5w10-lim-100-1 \
$DIS_JMETER_PROJ_PATH/charts/jmeter-rapi-helm-chart \
$DIS_JMETER_PROJ_PATH/charts/values/value.yaml \
10

```