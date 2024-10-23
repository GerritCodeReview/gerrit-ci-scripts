FROM debian:$DEBIAN_VER

USER root

RUN echo "deb http://http.debian.net/debian/ $DEBIAN_VER contrib" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update --allow-releaseinfo-change && apt-get install -y wget software-properties-common

RUN apt-get install -y default-jdk openjdk-17-jdk

COPY set-java.sh /usr/bin/

RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
    ant \
    autoconf \
    automake \
    build-essential \
    curl \
    gettext \
    gettext-base \
    iproute2 \
    lcov \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    libssl-dev \
    libz-dev \
    openssh-client \
    python3-distutils \
    python3-dev \
    python3-pip \
    python3-yaml \
    vim \
    xsltproc \
    zip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Debian 12 does not include the Java 11/21 packages
# therefore get them from the sid distribution and then
# reset the original package sources
RUN echo "deb http://deb.debian.org/debian sid main" >> /etc/apt/sources.list
RUN cp /etc/apt/sources.list /tmp/sources.list.save && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y openjdk-21-jdk-headless

COPY preferences /etc/apt/preferences
RUN echo "deb http://deb.debian.org/debian unstable main non-free contrib" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y openjdk-11-jdk-headless

RUN mv /tmp/sources.list.save /etc/apt/sources.list && \
    apt-get update

COPY requirements.txt /tmp/
RUN pip install --break-system-packages --require-hashes -r /tmp/requirements.txt

ADD https://www.kernel.org/pub/software/scm/git/git-$GIT_VER.tar.gz /tmp/
RUN tar xvfz /tmp/git-$GIT_VER.tar.gz && \
    cd git-$GIT_VER && \
    make prefix=/usr all install && \
    cd .. && rm -Rf git-$GIT_VER

ADD https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/$MAVEN_VER/apache-maven-$MAVEN_VER-bin.tar.gz /usr/local

RUN cd /usr/local && \
    tar xfz apache-maven-$MAVEN_VER-bin.tar.gz && \
    cd bin && ln -s ../apache-maven-$MAVEN_VER/bin/* .

RUN useradd jenkins -d /home/jenkins -m -s /bin/bash

COPY gitconfig $JENKINS_REF/.gitconfig

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

