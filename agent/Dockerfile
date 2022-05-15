FROM ghcr.io/linuxsuren/hd:v0.0.55 as downloader
FROM bitnami/kubectl:latest as kubectl

FROM jenkins/inbound-agent:alpine

MAINTAINER Seanly Liu<seanly@aliyun.com>

USER root

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update
COPY --from=downloader /usr/local/bin/hd /usr/local/bin/hd

RUN apk add --no-cache docker docker-compose supervisor curl busybox-extras \
  && apk add tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata

# install tools
RUN hd install rancher/dapper
COPY --from=kubectl /opt/bitnami/kubectl /opt/kubectl

RUN curl -o /tmp/kustomize.tar.gz -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.4/kustomize_v4.5.4_linux_amd64.tar.gz && \
  tar -x -f /tmp/kustomize.tar.gz -C /usr/bin/ && rm -rf /tmp/*.tar.gz

ENV PATH="/opt/kubectl/bin:$PATH"

# install jenkins-swarm client
ARG SWARM_VERSION=3.27
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client.jar \
    https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/swarm-client.jar

COPY ./rootfs /

VOLUME /var/lib/docker
EXPOSE 2375

ARG ENABLE_SERVICE=jenkins-agent
RUN mv /etc/supervisor/conf.d/${ENABLE_SERVICE}.conf.disable /etc/supervisor/conf.d/${ENABLE_SERVICE}.conf

RUN mkdir -p /var/log/supervisor/
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
