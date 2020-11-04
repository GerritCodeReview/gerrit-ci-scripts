#!/bin/bash

if [ -f $JENKINS_HOME/config.xml ]
then
  CONFIG=$JENKINS_HOME/config.xml
else
  CONFIG=$JENKINS_REF/config.xml
fi

echo "Make Docker socket accessible by Jenkins"
groupadd -g $DOCKER_GID dockergroup
usermod -g $DOCKER_GID jenkins

xsltproc \
  --stringparam use-security $USE_SECURITY \
  --stringparam docker-url $DOCKER_HOST \
  --stringparam oauth-client-id $OAUTH_ID \
  --stringparam oauth-client-secret $OAUTH_SECRET \
  $JENKINS_REF/edit-config.xslt $CONFIG > /tmp/config.xml.new
mv /tmp/config.xml.new $CONFIG

function config {
  git config -f /etc/jenkins_jobs/jenkins_jobs.ini $1 $2
}

config jenkins.user $JENKINS_API_USER
config jenkins.password $JENKINS_API_PASSWORD

mv /etc/jenkins_jobs/jenkins_jobs.ini /tmp/
cat /tmp/jenkins_jobs.ini | tr '-' '_' > /etc/jenkins_jobs/jenkins_jobs.ini

cp -R $JENKINS_REF/.ssh ~jenkins/.
chown -R jenkins:dockergroup ~jenkins
chmod 600 ~jenkins/.ssh/id_rsa
