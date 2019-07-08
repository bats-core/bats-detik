# DETIK: DevOps e2e Tests in Kubernetes
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Build Status](https://travis-ci.org/vincent-zurczak/devops-e2e-tests-in-kubernetes.svg?branch=master)](https://travis-ci.org/vincent-zurczak/devops-e2e-tests-in-kubernetes)

This repository provides utilities to **execute end-to-end tests** of applications in Kubernetes clusters. This includes performing actions on the cluster (with kubectl, oc - for OpenShift - or helm) and verifying assertions by using a natural language, or almost. This reduces the amount of advanced bash commands to master.

This kind of test is the ultimate set of verifications to run for a project, long after unit and integration tests. In fact, it is the last part of a pipeline for a project or a Helm package. The major assumption done here is that you have a test cluster, or at least a non-production one, to execute these tests.

> This tooling is inspired from [Pierre Mavro's article](https://blog.deimos.fr/2019/02/08/k8s-euft-run-functional-tests-on-your-helm-charts/), in particular for the BATS approach. However, it has the ambition of making such tests more simple to write. And it does not deal with the deployment of a K8s cluster.


## Table of Contents

* [Objectives](#objectives)
* [Examples](#examples)
  * [Test files and result](#test-files-and-result)
  * [Working with Kubectl or OC commands](#working-with-kubectl-or-oc-commands)
  * [Other Examples](#other-examples)

* [Usage](#usage)
  * [Setup](#setup)
  * [Executing tests by hand](#executing-tests-by-hand)
  * [Continuous Integration](#continuous-integration)

* [Syntax Reference](#syntax-reference)
* [Errors](#errors)
  * [Error Codes](#error-codes)
  * [Linting](#linting)


## Objectives

* Execute Helm / kubectl / oc commands and verify assertions on their output.
  * Example: get the right number of POD, make sure they are READY, etc.
* Execute application scenarios: 
  * Example: access a login page and follow a complex UI scenario (e.g. with [Selenium](https://www.seleniumhq.org/)).
  * Example: simulate events (e.g. the loss of a POD instance) and verify everything keeps on working.
  * Example: be able to play performance tests for a given configuration.
* Organize all the tests in scenarios.
* Obtain an execution report at the end.


## Examples

### Test files and result

This section shows how to write unit tests using this library and BATS.

```bash
load ../lib/detik
CLIENT_NAME="kubectl"

@test "verify the deployment" {
	
	run kubectl apply -f my-big-deployment-file.yml
	[ "$status" -eq 0 ]
	
	sleep 20
	
	run verify "there are 2 pods named 'nginx'"
	[ "$status" -eq 0 ]
	
	run verify "there is 1 service named 'nginx'"
	[ "$status" -eq 0 ]
	
	run try "at most 5 times every 30s to get pods named 'nginx' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
}


@test "verify the undeployment" {
	
	run kubectl delete -f my-big-deployment-file.yml
	[ "$status" -eq 0 ]
	
	sleep 20
	
	run verify "there are 0 pods named 'nginx'"
	[ "$status" -eq 0 ]
	
	run verify "there is 0 service named 'nginx'"
	[ "$status" -eq 0 ]
}
```

Running the command **bats my-tests.bats** would result in the following output...

```
bats my-tests.bats
1..2
✓ 1 verify the deployment
✓ 2 verify the undeployment
The command "bats my-tests.bats" exited with 0.
```

In case of error, it would show...

```
bats my-tests.bats
1..2
✗ 1 verify the deployment
    (in test file my-tests.bats, line 14)
     `[ "$status" -eq 0 ]' failed
 
✓ 2 verify the undeployment
The command "bats my-tests.bats" exited with 1.
```


## Working with Kubectl or OC commands

If you are working with a native Kubernetes cluster.

```bash
load ../lib/detik

# The client function.
CLIENT_NAME="kubectl"

# Verify the number of PODS and services
verify "there are 2 pods named 'nginx'"
verify "there is 1 service named 'nginx'"

# Verify assertions on resources
verify "'status' is 'running' for pods named 'nginx'"
verify "'port' is '8484' for services named 'nginx'"
verify "'.spec.ports[*].targetPort' is '8484' for services named 'nginx'"

# You can also specify a number of attempts
try "at most 5 times every 30s to get pods named 'nginx' and verify that 'status' is 'running'"
try "at most 5 times every 30s to get svc named 'nginx' and verify that '.spec.ports[*].targetPort' is '8484'"
```

If you work with OpenShift and would prefer to use **oc** instead of **kubectl**...

```bash
load ../lib/detik

# The client function.
CLIENT_NAME="oc"

# Verify the number of PODS and services
verify "there are 2 pods named 'nginx'"
```


## Other Examples

Examples are available under the **examples** directory.  
It includes...

* Library usage
* Tests for a Helm package
* Pipeline / CI integrations


## Usage

### Setup

* Install [BATS](https://github.com/sstephenson/bats), a testing framework for scripts.  
BATS is a test framework for BASH and other scripts.
* Download the **lib/detik.bash** script.  
```bash
wget https://raw.githubusercontent.com/vincent-zurczak/devops-e2e-tests-in-kubernetes/master/lib/lib.sh
chmod +x lib.sh
```
* Write bats scripts with assertions.  
Make sure they import the **lib/detik.bash** file.


### Executing Tests by Hand

Assuming you have built the image from the Dockerfile...

```bash
# Run the image with a volume for your project.
# In this example, we show how to specify the proxy
# if your organization is using one.
docker run -ti \
        -v $(pwd):/home/testing/sources \
        -e http_proxy="proxy.local:3128" \
        -e https_proxy="proxy.local:3128" \
        detik:LATEST

# Log into the cluster
echo "It all depends on your cluster configuration"

# Export the namespace for Helm (v2)
export TILLER_NAMESPACE=<your namespace>

# Execute the tests
bats sources/tests/main.bats
```


### Continuous Integration

An example is given for Jenkins in [the examples](examples/ci).  
The syntax is quite simple and may be easily adapted for other solutions, such as GitLab CI,
Tracis CI, etc.


## Syntax Reference

**Verify there is 0 or 1 resource of this type with this name pattern.**

```bash
verify "there is <0 or 1> <resource-type> named '<regular-expression>'"
```

*resource-type* is one of the K8s ones (e.g. `pods`, `po`, `services`, `svc`...).  
See [https://kubernetes.io/docs/reference/kubectl/overview/#resource-types](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types) for a complete reference.

**Verify there are N resources of this type with this name pattern.**

```bash
verify "there are <number> <resource-type> named '<regular-expression>'"
```

**Verify the property of a set of resources of this type with this name pattern.**

```bash
verify "'<property-name>' is '<expected-value>' for <resource-type> named '<regular-expression>'"
```

*property-name* if one of the column names supported by K8s.  
See https://kubernetes.io/docs/reference/kubectl/overview/#custom-columns  
You can also find column names by using `kubectl get <resource-type> -o custom-columns=ALL:*`.

To ease the writing of assertions, some aliases are proposed by the library.

| Alias        | Target Property           | Useful For |
| ------------ | ------------------------- | :--------: |
| status       | .status.phase             | PODS       |
| port         | .spec.ports[*].port       | Services   |
| targetPort   | .spec.ports[*].targetPort | Services   |

Other aliases may appear later.

**Attempt to verify the property of a set of resources of this type with this name pattern.**

```bash
try "at most <number> times every <number>s to get <resource-type> named '<regular-expression>' and verify that '<property-name>' is '<expected-value>'"
```

This is a checking loop.  
It breaks the loop if the values are found.


## Errors

### Error Codes

All the functions rely on the same convention.

| Exit Code | Meaning |
| --------- | ------- |
|     0     | Everything is fine. |
|     1     | The query for the function was empty. |
|     2     | The query did not respect the syntax. |
|     3     | The value could not be verified when the function returned. |


### Linting


