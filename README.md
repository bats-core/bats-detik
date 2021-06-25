# DETIK: DevOps e2e Testing in Kubernetes
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Build Status](https://travis-ci.org/bats-core/bats-detik.svg?branch=master)](https://travis-ci.org/bats-core/bats-detik)

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
  * [Counting Resources](#counting-resources)
  * [Verifying Property Values](#verifying-property-values)
  * [Property Names](#property-names)
* [Errors](#errors)
  * [Error Codes](#error-codes)
  * [Debugging Tests](#debugging-tests)
  * [Linting](#linting)
  * [Tips](#tips)


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
load "lib/utils"
load "lib/detik"

DETIK_CLIENT_NAME="kubectl"

@test "verify the deployment" {
	
	run kubectl apply -f my-big-deployment-file.yml
	[ "$status" -eq 0 ]
	
	sleep 20
	
	run verify "there are 2 pods named 'nginx'"
	[ "$status" -eq 0 ]
	
	run verify "there is 1 service named 'nginx'"
	[ "$status" -eq 0 ]
	
	run try "at most 5 times every 30s to find 2 pods named 'nginx' with 'status' being 'running'"
	[ "$status" -eq 0 ]
	
	run try "at most 5 times every 30s to get pods named 'nginx' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
}


@test "verify the undeployment" {
	
	run kubectl delete -f my-big-deployment-file.yml
	[ "$status" -eq 0 ]
	
	sleep 20
	
	run try "at most 5 times every 5s to find 0 pod named 'nginx' with 'status' being 'running'"
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

Since this project uses BATS, you can use **setup** and **teardown**
functions to prepare and clean after every test in a file.


## Working with Kubectl or OC commands

If you are working with a native Kubernetes cluster.

```bash
load "lib/utils"
load "lib/detik"

# The client function
DETIK_CLIENT_NAME="kubectl"

# If you want to work in a specific namespace.
# If not set, queries will be run in the default namespace.
DETIK_CLIENT_NAMESPACE="my-specific-namespace"

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

# Long assertions can also be split over several lines
try "at most 5 times every 30s " \
    "to get svc named 'nginx' " \
    "and verify that '.spec.ports[*].targetPort' is '8484'"
    
# You can also use an altered syntax, without global quotes.
# Be careful, you must then add double quotes around single ones.
try at most 5 times every 30s \
    to get svc named "'nginx'" \
    and verify that "'.spec.ports[*].targetPort'" is "'8484'"
```

If you work with OpenShift and would prefer to use **oc** instead of **kubectl**...

```bash
load "lib/utils"
load "lib/detik"

# The client function
DETIK_CLIENT_NAME="oc"

# Verify the number of PODS and services
verify "there are 2 pods named 'nginx'"
```


## Other Examples

Examples are available under [the eponym directory](examples/ci).  
It includes...

* Library usage
* Tests for a Helm package
* Pipeline / CI integrations


## Usage

### Manual Setup

* Install [BATS](https://github.com/bats-core/bats-core), a testing framework for scripts.  
BATS is a test framework for BASH and other scripts.
* Download the **lib/detik.bash** script.

```bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/detik.bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/linter.bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/utils.bash
chmod +x *.bash
```

* Write BATS scripts with assertions.  
Make sure they import the **lib/utils.bash** and **lib/detik.bash** files.
* Import the **lib/linter.bash** file to verify the linting of DETIK assertions.
* Use the BATS command to run your tests: `bats sources/tests/main.bats`


### Docker Setup

This project does not provide any official Docker image.  
This is because you may need various clients (kubectl, oc, kustomize...
whatever) and it all depends on your requirements.

A sample Dockerfile is provided in this project.  
To build a Docker image from it:

```bash
# Tag it with LATEST
docker build -t bats/bats-detik:LATEST .

# Overwrite the default versions
docker build \
	--build-arg KUBECTL_VERSION=v1.21.2 \
	--build-arg HELM_VERSION=v3.6.1 \
	--build-arg BATS_VERSION=1.3.0 \
	-t bats/bats-detik:LATEST \
	.    
```

On a development machine, you can use it this way:

```bash
# Run the image with a volume for your project.
# In this example, we show how to specify the proxy
# if your organization is using one.
docker run -ti \
	-v $(pwd):/home/testing/sources \
	-e http_proxy="proxy.local:3128" \
	-e https_proxy="proxy.local:3128" \
	bats-detik:LATEST

# Log into the cluster
echo "It all depends on your cluster configuration"

# Export the namespace for Helm (v2)
# export TILLER_NAMESPACE=<your namespace>

# Execute the tests
bats sources/tests/main.bats
```

It can also be used in a continuous integration platform.


### Continuous Integration

An example is given for Jenkins in [the examples](examples/ci).  
The syntax is quite simple and may be easily adapted for other solutions, such as GitLab CI, Tracis CI, etc.


## Syntax Reference

### Counting Resources

Verify there are N resources of this type with this name pattern.

```bash
# Expecting 0 or 1 instance
verify "there is <0 or 1> <resource-type> named '<regular-expression>'"

# Expecting more than 1 instance
verify "there are <number> <resource-type> named '<regular-expression>'"
```

*resource-type* is one of the K8s ones (e.g. `pods`, `po`, `services`, `svc`...).  
See [https://kubernetes.io/docs/reference/kubectl/overview/#resource-types](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types) for a complete reference.

This simple assertion may fail sometimes.  
As an example, if you count the number of PODs, run your test and then kill the POD, they will still
be listed, with the TERMINATING state. So, most of the time, you will want to verify the number of instances
with a given property value. Example: count the number of PODs with a given name pattern and having the `started` status.
Hence this additional syntax.

```bash
# Expecting 0 or 1 instance
try "at most <number> times every <number>s \
	to find <0 or 1> <resource-type> named '<regular-expression>' \
	with '<property-name>' being '<expected-value>'"

# Expecting more than 1 instance
try "at most <number> times every <number>s \
	to find <number> <resource-type> named '<regular-expression>' \
	with '<property-name>' being '<expected-value>'"
```

This is a checking loop.  
It breaks the loop if as soon as the assertion is verified. If it reaches the end of the loop
with having been verified, an error is thrown. Please, refer to [this section](#property-names) for details
about the property names.

This assertion is useful for PODs, whose life cycle changes take time.  
For services, you may directly use the simple count assertions.


### Verifying Property Values

Verify the property of a set of resources of this type with this name pattern.

```bash
verify "'<property-name>' is '<expected-value>' for <resource-type> named '<regular-expression>'"
```

Attempt to verify the property of a set of resources of this type with this name pattern.

```bash
try "at most <number> times every <number>s \
	to get <resource-type> named '<regular-expression>' \
	and verify that '<property-name>' is '<expected-value>'"
```

This is a checking loop.  
It breaks the loop if as soon as the assertion is verified. If it reaches the end of the loop
with having been verified, an error is thrown. Please, refer to [this section](#property-names) for details
about the property names.

This assertion verifies all the instances have this property value.
But unlike the assertion type to count resources, you do not verify how many instances have this value.


### Property Names

In all assertions, *property-name* if one of the column names supported by K8s.  
See https://kubernetes.io/docs/reference/kubectl/overview/#custom-columns  
You can also find column names by using `kubectl get <resource-type> -o custom-columns=ALL:*`.

To ease the writing of assertions, some aliases are proposed by the library.

| Alias        | Target Property           | Useful For |
| ------------ | ------------------------- | :--------: |
| status       | .status.phase             | PODS       |
| port         | .spec.ports[*].port       | Services   |
| targetPort   | .spec.ports[*].targetPort | Services   |

Other aliases may appear later.


## Errors

### Error Codes

All the functions rely on the same convention.

| Exit Code | Meaning |
| --------- | ------- |
|     0     | Everything is fine. |
|     1     | The query for the function was empty. |
|     2     | The query did not respect the syntax. |
|     3     | The assertion could not be verified when the function returned. It may also indicate an error with the K8s client. |


### Debugging Tests

There is a **debug** function in DETIK.  
You can use it in your own tests. Debug traces are stored into **/tmp/detik/**.
There is one debug file per test file.

It is recommended to reset this file at beginning of every test file.

```bash
#!/usr/bin/env bats

load "lib/utils"
load "lib/detik"


# Improve readability of the debug file
setup() {
	debug ""
	debug  ""
	debug  "-- $BATS_TEST_DESCRIPTION --"
	debug  ""
	debug  ""
}


@test "reset the debug file" {
	# This function is part of DETIK too
	reset_debug
}


@test "run my first test" {

	# Make an assertion and output the result in the debug file.
	run verify ...
	debug "Command output is: $output"
	[ "$status" -eq 0 ]
	
	# ...
}
```

DETIK debug messages are silenced by default.  
To enable them, you have to set the **DEBUG_DETIK** variable. In addition to your
own debug traces, you will see the ones from DETIK and/or its linter.

Here is an example showing how to debug DETIK with a test.

```bash
# Enable the debug flag
DEBUG_DETIK="true"
run verify "'status' is 'running' for pods named 'nginx'"

# Even if you did not log anything, DETIK did.
# Find the debug file under /tmp/detik.

# Reset the debug flag
DEBUG_DETIK=""
```


### Linting

Because Bash is not a compiled language, it is easy to make mistakes.  
Even if the library was designed to be simple. This is why a linter was created, to help to
locate syntax errors when writing DETIK assertions. You can use it with BATS in your tests.

```bash
#!/usr/bin/env bats
load "lib/utils"
load "lib/linter"

@test "lint assertions" {

	run lint "tests/my-tests-1.bats"
	# echo -e "$output" > /tmp/errors.txt
	[ "$status" -eq 0 ]
	
	run lint "tests/my-tests-2.bats"
	# echo -e "$output" > /tmp/errors.txt
	[ "$status" -eq 0 ]
}
```


### Tips

1. **Do not use file descriptors 3 and 4 in your tests.**  
They are already used by BATS. And 0, 1 and 2 are default file descriptors. Use 5, 6 and higher values.
