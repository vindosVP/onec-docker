ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE
ARG BASE_TAG
ARG user=jenkins

FROM ${DOCKER_REGISTRY_URL}/${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Gryzlov <NikGryzlov@1bit.com>, FirstBit"

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl \
      git \
      locales \
      openssh-client \
      wget \
      init \
      openssh-server openssh-client \
      apt-transport-https \
  # git-lfs
  && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git-lfs \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

RUN echo "deb http://security.ubuntu.com/ubuntu bionic-security main" | tee -a /etc/apt/sources.list
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32 && apt-get update 
#RUN apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && apt-get update
#RUN apt-get update && apt install -y openjdk-11-jdk


RUN groupadd -g 1000 jenkins \
  && useradd -l -d /home/jenkins -u 1000 -g 1000 -m jenkins


ARG AGENT_WORKDIR=/home/jenkins/agent

# Install jenkins jnlp
ARG VERSION=4.14
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/4.14/remoting-4.14.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar \
    && chown jenkins:jenkins /usr/share/jenkins/slave.jar

COPY ./jenkins-agent/jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent \
    && chown jenkins:jenkins /usr/local/bin/jenkins-agent \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN mkdir -p /home/jenkins/.jenkins \
    && mkdir -p /home/jenkins/agent \
    && chown -R jenkins:jenkins /home/jenkins


ENV LANG ru_RU.UTF-8

VOLUME /home/jenkins/.jenkins
VOLUME /home/jenkins/agent

WORKDIR /home/jenkins/agent

COPY ./jenkins-agent/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
