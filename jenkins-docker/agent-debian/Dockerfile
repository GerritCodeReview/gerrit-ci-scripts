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

