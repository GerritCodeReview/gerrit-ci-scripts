#!/bin/bash

JENKINS_URL=${JENKINS_URL:-http://localhost:8080}

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

sed -i -e "s/user=.*/user=$JENKINS_API_USER/" /etc/jenkins_jobs/jenkins_jobs.ini
sed -i -e "s/password=.*/password=$JENKINS_API_PASSWORD/" /etc/jenkins_jobs/jenkins_jobs.ini
git config -f /etc/jenkins_jobs/jenkins_jobs.ini jenkins.url $JENKINS_URL

cp -R $JENKINS_REF/.ssh ~jenkins/.
chown -R jenkins:dockergroup ~jenkins
chmod 600 ~jenkins/.ssh/id_rsa
