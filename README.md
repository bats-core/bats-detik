# DevOps e2e tests in Kubernetes
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Build Status](https://travis-ci.org/vincent-zurczak/devops-e2e-tests-in-kubernetes.svg?branch=master)](https://travis-ci.org/vincent-zurczak/devops-e2e-tests-in-kubernetes)

This repository provides utilities to **execute end-to-end tests** of applications in Kubernetes clusters. This includes performing actions on the cluster (with kubectl, oc - for OpenShift - or helm) and verifying assertions. This is the ultimate set of tests to run for a project, long after unit and integration tests. In fact, the last part of a pipeline for a project or a Helm package.

The major assumption done here is that you have a test cluster, or at least a non-production one, to execute these tests.

> This tooling is inspired from [Pierre Mavro's article](https://blog.deimos.fr/2019/02/08/k8s-euft-run-functional-tests-on-your-helm-charts/), in particular for the BATS approach. However, it has the ambition of making such tests more simple to write. And it does not deal with the deployment of a  K8s cluster.


## Objectives

* Execute Helm / kubectl / oc commands and verify assertions on their output.
  * Example: get the right number of POD, make sure they are READY, etc.
* Execute application scenarios: 
  * Example: access a login page and follow a complex UI scenario.
  * Example: simulate events (e.g. the loss of a POD instance) and verify everything keeps on working.
  * Example: be able to play performance tests for a given configuration.
* Organize all the tests in scenarios.
* Obtain an execution report at the end.


## Usage

* Install [BATS](https://github.com/sstephenson/bats), a testing framework for scripts.
* Download the **lib/lib.sh** script.
* Write bats scripts with assertions.  
Make sure they import the **lib.sh** file.

The library provides functions that allow to write assertions with a natural language, or almost. This reduces the amount of advanced bash commands to master.


## Examples (embedded in a BATS test)

This section shows how to write unit tests using this library and BATS.

```bash
source ../lib/lib.sh
CLIENT_NAME="kubectl"

@test "verify the deployment" {
	
	run kubectl apply -f my-big-deployment-file.yml
	[ "$status" -eq 0 ]
	
	sleep 20
	
	verify "there are 2 pods named 'nginx'"
	[ "$status" -eq 0 ]
	
	verify "there is 1 service named 'nginx'"
	[ "$status" -eq 0 ]
	
	try "at most 5 times every 30s to get pods named 'nginx' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
}


@test "verify the undeployment" {
	
	run kubectl delete -f my-big-deployment-file.yml
	[ "$status" -eq 0 ]
	
	sleep 20
	
	verify "there are 0 pods named 'nginx'"
	[ "$status" -eq 0 ]
	
	verify "there is 0 service named 'nginx'"
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


## Library Examples (kubectl / oc commands)

If you are working with a native Kubernetes cluster.

```bash
source ../lib/lib.sh

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
source ../lib/lib.sh

# The client function.
CLIENT_NAME="oc"

# Verify the number of PODS and services
verify "there are 2 pods named 'nginx'"
```


## Library Examples (helm commands)

Soon...


## Syntax

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

To ease the writing of assertions, some aliases are proposed by the library.

| Alias  | Target Property           | Useful For |
| ------ | ------------------------- | :--------: |
| status | .status.phase             | PODS       |
| port   | .spec.ports[*].targetPort | Services   |

Other aliases may appear later.

**Attempt to verify the property of a set of resources of this type with this name pattern.**

```bash
try "at most <number> times every <number>s to get <resource-type> named '<regular-expression>' and verify that '<property-name>' is '<expected-value>'"
```

This is a checking loop.  
It exits if the values are found.


## Error Codes

All the functions rely on the same convention.

| Exit Code | Meaning |
| --------- | ------- |
|     0     | Everything is fine. |
|     1     | If the query for the function was empty. |
|     2     | If the query did not respect the syntax. |
|     3     | If the value could not be verified when the function returned. |


## Installation

Before using this, you need to install BATS.  
BATS is a test framework for BASH and other scripts.
Please visit [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats) for more details.

Then download the library script and use it in your project.  
For the moment, it points to the snapshot version. Soon, tags will be available.

```bash
wget https://raw.githubusercontent.com/vincent-zurczak/devops-e2e-tests-in-kubernetes/master/lib/lib.sh
chmod +x lib.sh
```


## Usage in CI servers

A Docker image will soon be made available with everything necessary to execute such tests.
That includes kubectl, helm, BATS and this script.


## Roadmap

* Support "at least" and "less than" operators when couting resources.
* Create a Docker image to embed this script and related utilities.
* Write a blog post to explain what already exists and why this project was created.
* Demonstrate how to play user scenarios with Selenium, in conjunction with administration commands.
* Demonstrate how to run performance tests, in conjunction with administration commands.

