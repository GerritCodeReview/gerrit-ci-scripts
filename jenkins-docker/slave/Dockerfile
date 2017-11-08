FROM debian:stretch

USER root

RUN echo "deb http://http.debian.net/debian/ stretch contrib" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget gpg software-properties-common default-jdk openjdk-8-jdk && \
    update-java-alternatives -v -s java-1.8.0-openjdk-amd64

# Needed to support java 7 for older gerrit versions that used buck.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 86F44E2A
RUN sh -c 'echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu xenial main" > /etc/apt/sources.list.d/java.list'

# TODO remove once we no longer need to run buck under java 7
# this is a hack as java 7 is not in debian stretch
RUN cd /tmp && wget http://security.ubuntu.com/ubuntu/pool/main/f/fontconfig/fontconfig-config_2.11.94-0ubuntu1.1_all.deb && dpkg -i fontconfig-config_2.11.94-0ubuntu1.1_all.deb
RUN cd /tmp && wget http://security.ubuntu.com/ubuntu/pool/main/f/fontconfig/libfontconfig1_2.11.94-0ubuntu1.1_amd64.deb && dpkg -i libfontconfig1_2.11.94-0ubuntu1.1_amd64.deb
RUN cd /tmp && wget http://mirrors.kernel.org/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.4.2-0ubuntu3_amd64.deb && dpkg -i libjpeg-turbo8_1.4.2-0ubuntu3_amd64.deb
RUN cd /tmp && wget http://mirrors.kernel.org/ubuntu/pool/main/libj/libjpeg8-empty/libjpeg8_8c-2ubuntu8_amd64.deb && dpkg -i libjpeg8_8c-2ubuntu8_amd64.deb
RUN cd /tmp && wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb && dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN apt-get update && apt-get install -y openjdk-7-jdk

COPY set-java.sh /usr/bin/

RUN apt-get update && apt-get install -y \
    maven \
    openssh-server \
    curl \
    git-core \
    xvfb \
    python-dev \
    python-pip \
    python-yaml \
    python-jenkins \
    ant \
    autoconf \
    automake \
    xsltproc \
    zip \
    && rm -rf /var/lib/apt/lists/*

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

# Node JS for PolyGerrit build

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get install -y nodejs

# PolyGerrit tests

RUN curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get update && apt-get install -y google-chrome-stable

RUN npm install -g web-component-tester eslint eslint-config-google eslint-plugin-html polylint polymer-cli typescript fried-twinkie

COPY wct.conf.json /home/jenkins/
RUN chown jenkins:jenkins /home/jenkins/wct.conf.json

RUN apt-get install -y unzip wget
RUN mkdir /tmp/chromedriver/
ADD http://chromedriver.storage.googleapis.com/LATEST_RELEASE /tmp/chromedriver/LATEST_RELEASE
RUN wget -O /tmp/chromedriver/chromedriver.zip 'http://chromedriver.storage.googleapis.com/'$(cat /tmp/chromedriver/LATEST_RELEASE)'/chromedriver_linux64.zip'
RUN unzip /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/
RUN chmod a+x /usr/local/bin/chromedriver

# Allow Android SDK tools to run on a 64-bit system, see
# http://stackoverflow.com/a/23201209/1127485
RUN apt-get install -y lib32stdc++6 lib32z1

RUN /etc/init.d/ssh start

EXPOSE 22
CMD ["/usr/sbin/sshd", "-e", "-D"]
