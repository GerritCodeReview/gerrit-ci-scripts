FROM debian:stretch

USER root

RUN echo "deb http://http.debian.net/debian/ stretch contrib" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

ENV WCT_HEADLESS_MODE=1

RUN apt-get update && apt-get install -y wget gpg software-properties-common default-jdk openjdk-8-jdk && \
    update-java-alternatives -v -s java-1.8.0-openjdk-amd64

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

# pin Chrome version to 63.0.3239.108, stable chrome version on: 2018-01-24.
RUN sed -i -e 's/archive/old-releases/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget curl zip && \
    wget -O /tmp/chrome64_63.0.3239.108.deb https://www.slimjet.com/chrome/download-chrome.php?file=lnx%2Fchrome64_63.0.3239.108.deb && \
    apt-get install -y gdebi && \
    gdebi --non-interactive /tmp/chrome64_63.0.3239.108.deb

COPY wct.conf.json /home/jenkins/
RUN chown jenkins:jenkins /home/jenkins/wct.conf.json

RUN apt-get install -y unzip wget
RUN mkdir /tmp/chromedriver/
ADD http://chromedriver.storage.googleapis.com/LATEST_RELEASE /tmp/chromedriver/LATEST_RELEASE
RUN wget -O /tmp/chromedriver/chromedriver.zip 'http://chromedriver.storage.googleapis.com/'$(cat /tmp/chromedriver/LATEST_RELEASE)'/chromedriver_linux64.zip'
RUN unzip /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/
RUN chmod a+x /usr/local/bin/chromedriver

RUN npm install -g eslint eslint-config-google eslint-plugin-html typescript fried-twinkie polylint polymer-cli web-component-tester

# Allow Android SDK tools to run on a 64-bit system, see
# http://stackoverflow.com/a/23201209/1127485
RUN apt-get install -y lib32stdc++6 lib32z1

RUN /etc/init.d/ssh start

EXPOSE 22
CMD ["/usr/sbin/sshd", "-e", "-D"]
