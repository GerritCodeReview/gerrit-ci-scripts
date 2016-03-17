FROM jenkins

USER root

# Override Jenkins start-up script
RUN mv /usr/local/bin/jenkins.sh /usr/local/bin/run-jenkins.sh
COPY jenkins.sh /usr/local/bin/

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
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g web-component-tester

RUN apt-get install -y chromium chromedriver
RUN ln -s /usr/bin/chromium /usr/bin/chrome

# Unattended GUI testing
RUN apt-get install -y xvfb

# Building of Android apps
RUN [ -x ~/.android-sdk/tools/android ] || umake android android-sdk --accept-license ~/.android-sdk

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
#    ./autogen.sh && \
#    ./configure && \
#    make && \
#    make install
#
## END WATCHMAN SECTION ##

RUN mkdir -p /etc/jenkins_jobs && chown jenkins: /etc/jenkins_jobs

USER jenkins
COPY jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

ENV JENKINS_REF /usr/share/jenkins/ref/
ENV OAUTH_ID 326d197edb60653fdfcb
ENV OAUTH_SECRET ae9177**********************************
ENV JENKINS_API_USER lucamilanesio
ENV JENKINS_API_PASSWORD abc*************************

COPY config.xml $JENKINS_REF
COPY config.sh /usr/local/bin/
COPY plugins.txt $JENKINS_REF
RUN plugins.sh $JENKINS_REF/plugins.txt
COPY number-executors.groovy $JENKINS_REF/init.groovy.d/
RUN mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts/
COPY gerrit-ci-scripts.xml $JENKINS_REF/jobs/gerrit-ci-scripts/config.xml
RUN mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts-manual/
COPY gerrit-ci-scripts-manual.xml $JENKINS_REF/jobs/gerrit-ci-scripts-manual/config.xml

COPY gitconfig $JENKINS_REF/.gitconfig

