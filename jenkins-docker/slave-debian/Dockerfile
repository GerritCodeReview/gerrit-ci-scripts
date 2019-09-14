FROM debian:$DEBIAN_VER

USER root

RUN echo "deb http://http.debian.net/debian/ $DEBIAN_VER contrib" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget software-properties-common default-jdk

COPY set-java.sh /usr/bin/

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    python-dev \
    python-pip \
    python-yaml \
    python-jenkinsapi \
    ant \
    autoconf \
    automake \
    xsltproc \
    zip \
    vim \
    gettext-base \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libz-dev \
    libssl-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install python-jenkins

ADD https://www.kernel.org/pub/software/scm/git/git-$GIT_VER.tar.gz /tmp/
RUN tar xvfz /tmp/git-$GIT_VER.tar.gz && \
    cd git-$GIT_VER && \
    make prefix=/usr all install && \
    cd .. && rm -Rf git-$GIT_VER

ADD http://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VER/binaries/apache-maven-$MAVEN_VER-bin.tar.gz /usr/local

RUN cd /usr/local && \
    tar xfz apache-maven-$MAVEN_VER-bin.tar.gz && \
    cd bin && ln -s ../apache-maven-$MAVEN_VER/bin/* .

RUN useradd jenkins -d /home/jenkins -m -s /bin/bash
RUN mkdir /home/jenkins/.ssh
RUN chown -R jenkins:jenkins /home/jenkins/.ssh
RUN chmod -R 700 /home/jenkins/.ssh

COPY id_rsa.pub /home/jenkins/.ssh/authorized_keys
RUN chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys

COPY gitconfig $JENKINS_REF/.gitconfig

RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Allow Android SDK tools to run on a 64-bit system, see
# http://stackoverflow.com/a/23201209/1127485
RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1

# Install OpenJDK 8 for legacy stable Gerrit versions builds, releases and E2E tests
# TODO: to be removed when Gerrit v3.2 will be EOL
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt-get update && apt-get install adoptopenjdk-8-hotspot && \
    ln -s /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64 /usr/lib/jvm/java-8-openjdk-amd64

RUN /etc/init.d/ssh start

EXPOSE 22
CMD ["/usr/sbin/sshd", "-e", "-D"]
