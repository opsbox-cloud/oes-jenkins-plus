FROM jenkins/inbound-agent:alpine

LABEL dev.opsbox.image.author="Seanly Liu<seanly@opsbox.dev>" \
      dev.opsbox.image.name="jenkins-agent"

USER root

RUN apk update && \
    apk add --update --no-cache python3 py3-pip curl wget jq bash bash-completion neovim \ 
        ctags openssh-server openssh-client ansible fzf git rsync openssl openssl-dev \
        certbot ncurses sshpass busybox-extras bzip2 tmux supervisor &&\
    pip install jinja2-cli[yaml] && \
    apk add tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata 

# tools
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY --from=seanly/toolset:helm /usr/bin/helm /usr/bin/helm
COPY --from=seanly/toolset:kustomize /usr/bin/kustomize /usr/bin/kustomize
COPY --from=seanly/toolset:kubectl /usr/bin/kubectl /usr/bin/kubectl

# backup/oss
COPY --from=minio/mc /usr/bin/mc /usr/bin/mc
COPY --from=seanly/toolset:ossutil /usr/bin/ossutil* /usr/bin/ossutil

# docker
COPY --from=seanly/toolset:docker /install/docker/usr/bin/* /usr/bin/
COPY --from=seanly/toolset:docker /root/.docker /root/.docker
COPY --from=seanly/toolset:dapper /usr/bin/dapper /usr/bin/dapper

ENV DOCKER_CLI_EXPERIMENTAL=enabled
ENV DOCKER_BUILDKIT=1

RUN set -eux \
  && apk add --update --no-cache btrfs-progs e2fsprogs e2fsprogs-extra iptables xfsprogs xz pigz \
  && dockerd -v \
  && addgroup dockremap \
  && adduser -G dockremap -D -H dockremap \
  && echo 'dockremap:165536:65536' >> /etc/subuid \
  && echo 'dockremap:165536:65536' >> /etc/subgid \
  && addgroup docker \
  && adduser -G docker -D -H docker

VOLUME /var/lib/docker
EXPOSE 2375 2376

# install jenkins-swarm client
ARG SWARM_VERSION=3.39
RUN set -eux \
  && SWARM_URL=https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar \
  && curl --create-dirs -sSLo /usr/share/jenkins/swarm-client.jar ${SWARM_URL} \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/swarm-client.jar

COPY ./rootfs /

ENTRYPOINT [ "/entrypoint.sh" ]