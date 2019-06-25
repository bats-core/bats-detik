# DevOps e2e tests in Kubernetes

This repository provides utilities to **execute end-to-end tests** of applications in Kubernetes clusters. This includes performing actions on the cluster (with kubectl, oc - for OpenShift - or helm) and verifying assertions. This is the ultimate set of tests to run for a project, long after unit and integration tests. In fact, the last part of a pipeline for a project or a Helm package.

The major assumption done here is that you have a test cluster, or at least a non-production one, to execute these tests.

## Objectives

* Execute Helm / kubectl / oc commands and verify assertions on their output.  
  * Example: get the right number of POD, make sure they are READY, etc.
* Execute application scenarios: 
  * Example: access a login page and follow a complex UI scenario.
  * Example: simulate events (e.g. the loss of a POD instance) and verify everything keeps on working.
  * Example: be able to play performance tests for a given configuration.
* Organize all the tests in scenarios.
* Obtain an execution report at the end.

## Roadmap

* Provide generic functions to verify assertions by using K8s commands.  
  Ideally, tests using these functions should look like using a natural language.
* Handle the execution mecanisms.
* Deal with the generation of reports (text, HTML, markdown).
* Write a blog post to explain what already exists and why this project was created.
* Demonstrate how to play user scenarios with Selenium, in conjunction with administration commands.
* Demonstrate how to run performance tests, in conjunction with administration commands.
