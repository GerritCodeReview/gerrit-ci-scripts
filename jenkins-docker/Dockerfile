FROM jenkins

USER root

ENV GOPATH /usr/local/go

RUN apt-get update && apt-get install -y \
    python-pip \
    python-yaml \
    python-jenkins \
    ant \
    default-jdk \
    golang \
    autoconf \
    automake \
    maven \
    && rm -rf /var/lib/apt/lists/* \
    && go get "github.com/robfig/cron"

RUN mkdir -p /opt/ && git clone https://git.openstack.org/openstack-infra/jenkins-job-builder /opt/jenkins_job_builder

RUN pip install /opt/jenkins_job_builder

RUN git clone https://github.com/facebook/buck /opt/buck && \
    cd /opt/buck && ant && \
    mkdir -p /opt/buck/bin && \
    ln -s `pwd`/bin/buck /usr/bin/ && \
    ln -s `pwd`/bin/buckd /usr/bin/ && \
    chown -R jenkins:jenkins /opt/buck

RUN git clone https://github.com/facebook/watchman.git /opt/watchman && \
    cd /opt/watchman && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

RUN mkdir -p /etc/jenkins_jobs
COPY jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

COPY update-jobs.sh /usr/local/bin/update-jobs.sh
RUN chmod 0755 /usr/local/bin/update-jobs.sh
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod 0755 /usr/local/bin/startup.sh
COPY startup.go /usr/local/bin/startup.go

USER jenkins

ENTRYPOINT /usr/local/bin/startup.sh

COPY plugins.txt /usr/share/jenkins/ref/
RUN plugins.sh /usr/share/jenkins/ref/plugins.txt
COPY number-executors.groovy /usr/share/jenkins/ref/init.groovy.d/

COPY gitconfig /usr/share/jenkins/ref/.gitconfig
