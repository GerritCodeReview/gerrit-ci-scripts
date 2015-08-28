FROM jenkins

USER root

RUN apt-get update && apt-get install -y \
    python-pip \
    python-yaml \
    python-jenkins \
    ant \
    default-jdk \
    autoconf \
    automake \
    maven \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ && git clone https://git.openstack.org/openstack-infra/jenkins-job-builder /opt/jenkins_job_builder

RUN pip install /opt/jenkins_job_builder

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
#    git checkout v3.7.0 && \
#    ./autogen.sh && \
#    ./configure && \
#    make && \
#    make install
#
## END WATCHMAN SECTION ##

RUN mkdir -p /etc/jenkins_jobs
COPY jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/
RUN plugins.sh /usr/share/jenkins/ref/plugins.txt
COPY number-executors.groovy /usr/share/jenkins/ref/init.groovy.d/
RUN mkdir -p /usr/share/jenkins/ref/jobs/gerrit-ci-scripts/
COPY gerrit-ci-scripts.xml /usr/share/jenkins/ref/jobs/gerrit-ci-scripts/config.xml
RUN mkdir -p /usr/share/jenkins/ref/jobs/gerrit-ci-scripts-manual/
COPY gerrit-ci-scripts-manual.xml /usr/share/jenkins/ref/jobs/gerrit-ci-scripts-manual/config.xml

COPY gitconfig /usr/share/jenkins/ref/.gitconfig
