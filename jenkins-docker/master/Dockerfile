FROM jenkins:2.3

USER root

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
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ && git clone https://git.openstack.org/openstack-infra/jenkins-job-builder /opt/jenkins_job_builder

RUN pip install /opt/jenkins_job_builder

RUN mkdir -p /etc/jenkins_jobs && chown jenkins: /etc/jenkins_jobs
COPY jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false -Dhudson.model.ParametersAction.keepUndefinedParameters=true
ENV JENKINS_REF /usr/share/jenkins/ref/
ENV USE_SECURITY false
ENV OAUTH_ID clientid
ENV OAUTH_SECRET secret
ENV JENKINS_API_USER user
ENV JENKINS_API_PASSWORD pass
ENV DOCKER_HOST tcp://127.0.0.1:2375

COPY edit-config.xslt $JENKINS_REF
COPY config.xml $JENKINS_REF

RUN mkdir $JENKINS_REF/.ssh
RUN chown -R jenkins:jenkins $JENKINS_REF/.ssh
RUN chmod -R 700 $JENKINS_REF/.ssh

COPY config.sh /usr/local/bin/
COPY plugins.txt $JENKINS_REF
RUN plugins.sh $JENKINS_REF/plugins.txt
COPY number-executors.groovy $JENKINS_REF/init.groovy.d/
RUN mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts/
COPY gerrit-ci-scripts.xml $JENKINS_REF/jobs/gerrit-ci-scripts/config.xml
RUN mkdir -p $JENKINS_REF/jobs/gerrit-ci-scripts-manual/
COPY gerrit-ci-scripts-manual.xml $JENKINS_REF/jobs/gerrit-ci-scripts-manual/config.xml

RUN echo "2.0" > $JENKINS_REF/jenkins.install.UpgradeWizard.state
RUN echo "2.0" > $JENKINS_REF/upgraded
RUN echo "2.0" > $JENKINS_REF/.last_exec_version

COPY gitconfig $JENKINS_REF/.gitconfig

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-cache policy docker-engine
RUN apt-get install -y docker-engine

COPY id_rsa* $JENKINS_REF/.ssh/
RUN chown jenkins:jenkins $JENKINS_REF/.ssh/id_rsa*
RUN chmod 600 $JENKINS_REF/.ssh/id_rsa

USER jenkins



