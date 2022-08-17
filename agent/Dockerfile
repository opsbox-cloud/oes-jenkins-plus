FROM ghcr.io/linuxsuren/hd:v0.0.55 as downloader

FROM jenkins/inbound-agent:alpine

MAINTAINER Seanly Liu<seanly@aliyun.com>

USER root
COPY --from=downloader /usr/local/bin/hd /usr/local/bin/hd

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache docker docker-compose supervisor curl busybox-extras bash vim && \
    apk add tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

ARG ARCH=amd64

# install tools
RUN hd install rancher/dapper

ENV HELM_VERSION v3.9.0
ENV KUSTOMIZE_VERSION v4.5.5
ENV ETCD_VERSION v3.5.1

ENV HELM_URL_V3=https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz \
    ETCD_URL=https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz \
    KUSTOMIZE_URL=https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz

# set up helm 3 and kustomize
RUN curl ${HELM_URL_V3} | tar xvzf - --strip-components=1 -C /usr/bin && \
    curl -sLf ${KUSTOMIZE_URL} | tar -xzf - -C /usr/bin && \
    chmod +x /usr/bin/kustomize

# Set up K3s: copy the necessary binaries from the K3s image.
COPY --from=rancher/k3s:v1.22.6-k3s1 \
    /bin/blkid \
    /bin/charon \
    /bin/cni \
    /bin/conntrack \
    /bin/containerd \
    /bin/containerd-shim-runc-v2 \
    /bin/ethtool \
    /bin/ip \
    /bin/ipset \
    /bin/k3s \
    /bin/losetup \
    /bin/pigz \
    /bin/runc \
    /bin/swanctl \
    /bin/which \
    /bin/aux/xtables-legacy-multi \
/usr/bin/

RUN ln -s /usr/bin/cni /usr/bin/bridge && \
    ln -s /usr/bin/cni /usr/bin/flannel && \
    ln -s /usr/bin/cni /usr/bin/host-local && \
    ln -s /usr/bin/cni /usr/bin/loopback && \
    ln -s /usr/bin/cni /usr/bin/portmap && \
    ln -s /usr/bin/k3s /usr/bin/k3s-agent && \
    ln -s /usr/bin/k3s /usr/bin/k3s-etcd-snapshot && \
    ln -s /usr/bin/k3s /usr/bin/k3s-server && \
    ln -s /usr/bin/k3s /usr/bin/kubectl && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-save && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-restore && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/iptables-translate && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-save && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-restore && \
    ln -s /usr/bin/xtables-legacy-multi /usr/bin/ip6tables-translate

RUN mkdir -p /var/lib/rancher/k3s/agent/images/ && \
    curl -sfL ${ETCD_URL} | tar xvzf - --strip-components=1 -C /usr/bin/ etcd-${ETCD_VERSION}-linux-${ARCH}/etcdctl

ARG VERSION=dev

ENV OPSBOX_SERVER_VERSION ${VERSION}

ENV ETCDCTL_API=3

ENV SSL_CERT_DIR /etc/rancher/ssl
VOLUME /var/lib/kubelet
VOLUME /var/lib/rancher/k3s
VOLUME /var/lib/cni
VOLUME /var/log
VOLUME /var/lib/docker

ENV PATH="$PATH:/bin/aux"

ENV CRI_CONFIG_FILE="/var/lib/rancher/k3s/agent/etc/crictl.yaml"

# install jenkins-swarm client
ARG SWARM_VERSION=3.27
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client.jar \
    https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/swarm-client.jar

COPY ./rootfs /

EXPOSE 2375

ARG ENABLE_SERVICE=jenkins-agent
RUN mv /etc/supervisor/conf.d/${ENABLE_SERVICE}.conf.disable /etc/supervisor/conf.d/${ENABLE_SERVICE}.conf

RUN mkdir -p /var/log/supervisor/
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
