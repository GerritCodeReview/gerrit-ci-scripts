ARG JENKINS_WAR_VER
FROM jenkins/jenkins:${JENKINS_WAR_VER}

USER root

ARG JENKINS_WAR_SHA
RUN echo "$JENKINS_WAR_SHA /usr/share/jenkins/jenkins.war" | sha256sum -c -

# Override Jenkins start-up script
RUN mv /usr/local/bin/jenkins.sh /usr/local/bin/run-jenkins.sh
COPY jenkins.sh /usr/local/bin/

RUN apt-get update && apt-get install -y \
    ca-certificates \
    python-dev-is-python3 \
    python3-pip \
    python3-yaml \
    default-jdk \
    autoconf \
    automake \
    xsltproc \
    wget \
    lsb-release \
    apt-transport-https && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/jenkins_jobs && chown jenkins: /etc/jenkins_jobs

RUN sed -i 's#mozilla/DST_Root_CA_X3.crt#!mozilla/DST_Root_CA_X3.crt#' /etc/ca-certificates.conf && \
    update-ca-certificates

COPY requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages --require-hashes -r /tmp/requirements.txt

COPY jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false -Dhudson.model.ParametersAction.keepUndefinedParameters=true
ENV JENKINS_REF /usr/share/jenkins/ref
ENV USE_SECURITY false
ENV OAUTH_ID clientid
ENV OAUTH_SECRET secret
ENV JENKINS_API_USER user
ENV JENKINS_API_PASSWORD pass
ENV REMOTE_DOCKER_HOST unix:///var/run/docker.sock
ENV BINTRAY_URL https://dl.bintray.com/lucamilanesio

COPY edit-config.xslt $JENKINS_REF
COPY config.xml $JENKINS_REF
COPY jenkins.plugins.logstash.LogstashInstallation.xml $JENKINS_REF
COPY jenkins.model.JenkinsLocationConfiguration.xml $JENKINS_REF
COPY org.codefirst.SimpleThemeDecorator.xml $JENKINS_REF

RUN mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts/ && \
    mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts-manual/

COPY number-executors.groovy $JENKINS_REF/init.groovy.d/
COPY setCredentials.groovy $JENKINS_REF/init.groovy.d/

# TODO: CVE-2024-23897 Groovy workaround can be removed only after upgrading to 2.442, LTS 2.426.3
COPY CVE-2024-23897-disable-cli.groovy $JENKINS_REF/init.groovy.d/

ARG SERVER_TYPE
COPY gerrit-ci-scripts-$SERVER_TYPE.xml $JENKINS_REF/jobs/gerrit-ci-scripts/config.xml
COPY gerrit-ci-scripts-manual-$SERVER_TYPE.xml $JENKINS_REF/jobs/gerrit-ci-scripts-manual/config.xml
COPY org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml $JENKINS_REF/

RUN echo "2.0" > $JENKINS_REF/jenkins.install.UpgradeWizard.state && \
    echo "2.0" > $JENKINS_REF/upgraded && \
    echo "2.0" > $JENKINS_REF/.last_exec_version

COPY gitconfig $JENKINS_REF/.gitconfig

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    dirmngr \
    gpgv && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-cache policy docker-engine && \
    apt-get install -y docker-ce-cli=5:25.0.3-1~debian.12~bookworm

COPY config.sh /usr/local/bin/

# Install gosu
ENV GOSU_VERSION 1.14
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ARG PLUGIN_FILE
COPY $PLUGIN_FILE $JENKINS_REF/plugins.txt
RUN jenkins-plugin-cli -f $JENKINS_REF/plugins.txt

RUN chown -R jenkins:jenkins $JENKINS_REF

ENV DOCKER_GID=993

USER root
