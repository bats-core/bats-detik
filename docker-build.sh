#!/bin/bash

echo
echo "Building the image..."
echo

version=0.2
docker build \
		--build-arg KUBECTL_VERSION=v1.14.1 \
		--build-arg HELM_VERSION=v2.13.1 \
		-t vincent-zurczak/detik:latest \
		-t vincent-zurczak/detik:$version \
		.

