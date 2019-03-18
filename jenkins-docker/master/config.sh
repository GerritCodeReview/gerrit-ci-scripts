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
  $JENKINS_REF/edit-config.xslt $CONFIG > /tmp/config.xml.new
mv /tmp/config.xml.new $CONFIG

cp -R $JENKINS_REF/.ssh ~jenkins/.
chown -R jenkins:dockergroup ~jenkins
chmod 600 ~jenkins/.ssh/id_rsa
