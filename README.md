# distributed-jmeter-rapi-k8s


<img width="1694" alt="kubernetes-infra" src="https://github.com/bobcode99/distributed-jmeter-rapi-k8s/assets/39816893/6ac3330f-3c7d-4984-ad0f-6946fed891a4">

## Introduction

This sample repository provides everything you need to run Apache JMeter distributed testing with Rapi using Kubernetes. It includes all the necessary components and configurations to set up the environment.

### Docker images

This repository provides a sample Docker image that utilizes selenium/standalone-chrome:113.0 as the base image. Inside the Docker image, you'll find JMeter, jmeter-rapi-plugin, Rapi Runner, Selenium, Chrome, and jmx_exporter.

### Load Test Script

A script that helps you deploy one JMeter controller and several JMeter worker to run [Distributed JMeter](https://jmeter.apache.org/usermanual/jmeter_distributed_testing_step_by_step.html) with jmeter-rapi-plugin front end load test easily.

### Helm Charts

A sample Helm Charts that declare the Kubernetes deployment, service you need.

## Steps

### Need prepare

1. Kubernetes Cluster
2. Helm cli


### Step 1
Declare the project path variable. You should change it to your path.

Don't forget to modify the `KUBE_CONFIG_PATH` in `./script/start-test-rapi.sh`. Set it to your Kubernetes config path file.

```bash
export DIS_JMETER_PROJ_PATH=/home/user/Downloads/distributed-jmeter-rapi-k8s
```

### Step 2

Execute the load test script.

Currently need provide these input to the bash script

1. The JMeter testplan path.
2. THe Rapi test case path.
3. The Kubernetes namespaces name.
4. The Helm Chart name.
5. The Helm Chart path.
6. The Helm Chart value path.

   This value define the resources that JMeter controller, worker pod needed.

7. The number of JMeter worker.

In this example, a 5 thread JMeter test plan will be run for 1 hour. And 10 worker pods will be deployed. In other words, this test case will run 50 Chrome front-end load tests for 1 hour.

5 thread \* 10 worker pod = 50 Thread(Browser)

3600 seconds equal to 1 hour.

Sample:

```bash
./script/start-test-rapi.sh \
$DIS_JMETER_PROJ_PATH/jmeter-test-plan/rapiTestPlanUseForK8s-manythread-with-synctimer-loop1hour.jmx \
$DIS_JMETER_PROJ_PATH/rapi-test-suites/sample-test-suite.json \
ns-jmeter-rapi--wordp-a80b20useb20--t5w10-lim-100-1 \
helm--wau--t5w10-lim-100-1 \
$DIS_JMETER_PROJ_PATH/charts/jmeter-rapi-helm-chart \
$DIS_JMETER_PROJ_PATH/charts/values/value.yaml \
10
```

Once you execute the script, it will wait for the successful deployment of the JMeter worker and controller pods. Afterward, it will start running the load test.

Once the test is completed, the script will copy the results.csv file from the controller, as well as the logs of both the controller and worker pods. This allows you to conveniently access the test results and review the logs for analysis.

### Step 3

Finally, don't forget to delete the namespaces.

```
kubectl delete namespace ${NAMESPACE_NAME}
```

## Debug use

```
helm install --dry-run --debug --namespace test-ns-jmeter-rapi100 helm-chart-jr-test $DIS_JMETER_PROJ_PATH/charts/jmeter-rapi-helm-chart --set worker_replica=5 --values $DIS_JMETER_PROJ_PATH/charts/values/value.yaml
```

```bash
./script/start-test-rapi.sh \
/path/to/jmeterTestPlan.jmx \
/path/to/rapiTestSuite.json \
namespacename-jmeter-rapi \
helm-chart-name-jr \
/path/to/jmeter-rapi-helm-chart \
/path/to/helm-char-value/value.yaml \
10
```