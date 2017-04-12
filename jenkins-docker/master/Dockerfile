FROM jenkins:latest

USER root

ARG JENKINS_WAR_VER=2.15
ARG JENKINS_WAR_SHA=9d9c237c4a573f415679f36421de7c0b57fc2d3e

# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_WAR_VER}/jenkins-war-${JENKINS_WAR_VER}.war -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_WAR_SHA  /usr/share/jenkins/jenkins.war" | sha1sum -c -

# Override Jenkins start-up script
RUN mv /usr/local/bin/jenkins.sh /usr/local/bin/run-jenkins.sh
COPY jenkins.sh /usr/local/bin/

RUN apt-get update && apt-get install -y \
    python-dev \
    python-pip \
    python-yaml \
    python-jenkins \
    default-jdk \
    autoconf \
    automake \
    xsltproc \
    apt-transport-https && \
    rm -rf /var/lib/apt/lists/* && \
    \
    mkdir -p /opt/ && \
    git clone https://git.openstack.org/openstack-infra/jenkins-job-builder /opt/jenkins_job_builder && \
    cd /opt/jenkins_job_builder && git checkout 1.6.2 && \
    pip install /opt/jenkins_job_builder && \
    mkdir -p /etc/jenkins_jobs && chown jenkins: /etc/jenkins_jobs

COPY jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false -Dhudson.model.ParametersAction.keepUndefinedParameters=true
ENV JENKINS_REF /usr/share/jenkins/ref/
ENV USE_SECURITY false
ENV OAUTH_ID clientid
ENV OAUTH_SECRET secret
ENV JENKINS_API_USER user
ENV JENKINS_API_PASSWORD pass
ENV BINTRAY_URL https://dl.bintray.com/lucamilanesio

COPY edit-config.xslt $JENKINS_REF
COPY config.xml $JENKINS_REF
COPY jenkins.plugins.logstash.LogstashInstallation.xml $JENKINS_REF

RUN mkdir $JENKINS_REF/.ssh && \
    chown -R jenkins:jenkins $JENKINS_REF/.ssh && \
    chmod -R 700 $JENKINS_REF/.ssh

COPY plugins.txt $JENKINS_REF
RUN cat $JENKINS_REF/plugins.txt | xargs install-plugins.sh
# Snapshot build of the Jenkins Docker Plugin (includes unix:/// sockets fix)
ADD $BINTRAY_URL/jenkins-snapshots/com/nirima/docker-plugin/0.16.1-54-gc5c5be1/docker-plugin-0.16.1-54-gc5c5be1.hpi $JENKINS_REF/plugins/docker-plugin.jpi
RUN chown -R jenkins:jenkins $JENKINS_REF

RUN mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts/ && \
    mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts-manual/

COPY number-executors.groovy $JENKINS_REF/init.groovy.d/
COPY gerrit-ci-scripts.xml $JENKINS_REF/jobs/gerrit-ci-scripts/config.xml
COPY gerrit-ci-scripts-manual.xml $JENKINS_REF/jobs/gerrit-ci-scripts-manual/config.xml

RUN echo "2.0" > $JENKINS_REF/jenkins.install.UpgradeWizard.state && \
    echo "2.0" > $JENKINS_REF/upgraded && \
    echo "2.0" > $JENKINS_REF/.last_exec_version

COPY gitconfig $JENKINS_REF/.gitconfig

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-cache policy docker-engine && \
    apt-get install -y docker-engine=1.11.2-0~jessie

COPY id_rsa* $JENKINS_REF/.ssh/
RUN chown jenkins:jenkins $JENKINS_REF/.ssh/id_rsa* && \
    chmod 600 $JENKINS_REF/.ssh/id_rsa

COPY config.sh /usr/local/bin/

# Install gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Set default JDK to 8
RUN apt-get install -y openjdk-8-jdk && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

USER root


