FROM ubuntu:15.04

USER root

RUN apt-get update && apt-get install -y \
    python-dev \
    python-pip \
    python-yaml \
    python-jenkins \
    ant \
    default-jdk \
    autoconf \
    automake \
    maven \
    xsltproc \
    openjdk-7-jdk \
    openssh-server \
    curl \
    git-core \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g web-component-tester

RUN apt-get install -y chromium-browser
RUN ln -s /usr/bin/chromium /usr/bin/chrome

RUN apt-get install -y unzip wget
RUN mkdir /tmp/chromedriver/
ADD http://chromedriver.storage.googleapis.com/LATEST_RELEASE /tmp/chromedriver/LATEST_RELEASE
RUN wget -O /tmp/chromedriver/chromedriver.zip 'http://chromedriver.storage.googleapis.com/'$(cat /tmp/chromedriver/LATEST_RELEASE)'/chromedriver_linux64.zip'
RUN unzip /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/
RUN chmod a+x /usr/local/bin/chromedriver

# Unattended GUI testing
RUN apt-get install -y xvfb

# Allow Android SDK tools to run on a 64-bit system, see
# http://stackoverflow.com/a/23201209/1127485
RUN apt-get install -y lib32stdc++6 lib32z1

RUN mkdir -p /opt/ && git clone https://git.openstack.org/openstack-infra/jenkins-job-builder /opt/jenkins_job_builder

RUN pip install /opt/jenkins_job_builder

RUN useradd jenkins -d /home/jenkins -m -s /bin/bash
RUN mkdir /home/jenkins/.ssh
RUN chown -R jenkins:jenkins /home/jenkins/.ssh
RUN chmod -R 700 /home/jenkins/.ssh

COPY id_rsa.pub /home/jenkins/.ssh/authorized_keys
RUN chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys

USER root
RUN git clone https://github.com/facebook/buck /opt/buck && \
    cd /opt/buck && ant && \
    mkdir -p /opt/buck/bin && \
    ln -s `pwd`/bin/buck /usr/bin/ && \
    ln -s `pwd`/bin/buckd /usr/bin/ && \
    chown -R jenkins:jenkins /opt/buck

## NOTE ##
# Watchman can be enabled (to enable buckd) by uncommenting the following
# lines.  Note that because this caches some build results, it can lead to
# unpredictable behavior in a continuous integration setting.
# ENABLE AT YOUR OWN RISK!
#
#RUN git clone https://github.com/facebook/watchman.git /opt/watchman && \
#    cd /opt/watchman && \
#    ./autogen.sh && \
#    ./configure && \
#    make && \
#    make install
#
## END WATCHMAN SECTION ##

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

COPY gitconfig $JENKINS_REF/.gitconfig

RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN /etc/init.d/ssh start

EXPOSE 22
CMD ["/usr/sbin/sshd", "-e", "-D"]
