# distributed-jmeter-rapi-k8s

Apache JMeter distributed testing with Rapi.

```
export DIS_JMETER_PROJ_PATH=/home/selab/jmeter-proj-use/distributed-jmeter-rapi-k8s

./script/start-test-rapi.sh $DIS_JMETER_PROJ_PATH/test-plan-folder/rapiTestPlanUseTCForK8s-manythread.jmx $DIS_JMETER_PROJ_PATH/sideex-test-case/wordpress-a-b-testing-8020-suite-recordb20-noscroll.json jmeter-rapi--wordp-a80b20useb20--t5w10-lim-551041-1 helm--wau--t5w10-lim-551041-1 $DIS_JMETER_PROJ_PATH/helm-jmeter-sideex-app 10

```