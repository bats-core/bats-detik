FROM alpine:3.14

ARG KUBECTL_VERSION=v1.21.2
ARG HELM_VERSION=v3.6.1
ARG BATS_VERSION=1.3.0

# Add packages
RUN apk --no-cache add \
    curl \
    git \
    libc6-compat \
    openssh-client \
    bash

# Install BATS
RUN curl -LO "https://github.com/bats-core/bats-core/archive/refs/tags/v$BATS_VERSION.zip" && \
	unzip -q -d /tmp "v$BATS_VERSION.zip" && \
	cd "/tmp/bats-core-$BATS_VERSION" && \
	./install.sh /usr/local && \
	rm -rf "/tmp/bats-core-$BATS_VERSION"

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" && \
	chmod +x kubectl && \
	mv kubectl /usr/local/bin/

# Install Helm
RUN curl -LO "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" && \
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

# Initialize the Helm client (Helm 2.x)
# RUN helm init --client-only --skip-refresh

# Add the library
COPY ./lib /home/testing/lib
