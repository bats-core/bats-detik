FROM alpine:3.10

ARG KUBECTL_VERSION=v1.14.1
ARG HELM_VERSION=v2.13.1

# Add packages
RUN apk --no-cache add \
    curl \
    git \
    libc6-compat \
    openssh-client \
    bash

# Install BATS 1.1.0
RUN curl -LO https://github.com/bats-core/bats-core/archive/v1.1.0.zip && \
	unzip -q -d /tmp v1.1.0.zip && \
	cd /tmp/bats-core-1.1.0 && \
	./install.sh /usr/local && \
	rm -rf /tmp/bats-core-1.1.0

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" && \
	chmod +x kubectl && \
	mv kubectl /usr/local/bin/

# Install Helm
RUN curl -LO "https://kubernetes-helm.storage.googleapis.com/helm-$HELM_VERSION-linux-amd64.tar.gz" && \
	mkdir -p "/usr/local/helm-$HELM_VERSION" && \
	tar -xzf "helm-$HELM_VERSION-linux-amd64.tar.gz" -C "/usr/local/helm-$HELM_VERSION" && \
	ln -s "/usr/local/helm-$HELM_VERSION/linux-amd64/helm" /usr/local/bin/helm && \
	rm -f "helm-$HELM_VERSION-linux-amd64.tar.gz"

# Work directory.
# Use the same UID than Jenkins:
# for Jenkins versions < 2.62, this is 1000
RUN adduser -D -u 10000 testing
USER testing
WORKDIR /home/testing

# Initialize the Helm client
RUN helm init --client-only --skip-refresh

# Add the library
COPY ./lib /home/testing/lib

