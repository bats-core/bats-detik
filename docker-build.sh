#!/bin/bash

echo
echo "Building the image..."
echo

version=0.1
docker build \
		--build-arg KUBECTL_VERSION=v1.14.1 \
		--build-arg HELM_VERSION=v2.13.1 \
		-t vincent-zurczak/devops-e2e-tests-in-kubernetes:latest \
		-t vincent-zurczak/devops-e2e-tests-in-kubernetes:$version \
		.

