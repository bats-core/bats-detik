#!/bin/bash

echo
echo "Building the image..."
echo

version=0.2
docker build \
		--build-arg KUBECTL_VERSION=v1.14.1 \
		--build-arg HELM_VERSION=v2.13.1 \
		-t bats/bats-detik:latest \
		-t bats/bats-detik:$version \
		.
