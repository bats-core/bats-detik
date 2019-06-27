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
    
# Install BATS
RUN git clone https://github.com/sstephenson/bats.git && \
	cd bats && \
	./install.sh /usr/local

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

# Work directory
RUN mkdir -p /home/testing
WORKDIR /home/testing

# Add the library
COPY ./lib /home/testing/lib

