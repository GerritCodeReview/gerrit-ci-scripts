#!/bin/bash

if [ -f $JENKINS_HOME/config.xml ]
then
  CONFIG=$JENKINS_HOME/config.xml
else
  CONFIG=$JENKINS_REF/config.xml
fi

echo "Make Docker socket accessible by Jenkins"
groupadd -g 993 dockergroup
usermod -g 993 jenkins

xsltproc \
  --stringparam use-security $USE_SECURITY \
  --stringparam docker-url $DOCKER_HOST \
  $JENKINS_REF/edit-config.xslt $CONFIG > /tmp/config.xml.new
mv /tmp/config.xml.new $CONFIG

sed -i -e "s/user=.*/user=$JENKINS_API_USER/" /etc/jenkins_jobs/jenkins_jobs.ini
sed -i -e "s/password=.*/password=$JENKINS_API_PASSWORD/" /etc/jenkins_jobs/jenkins_jobs.ini

cp -R $JENKINS_REF/.ssh ~jenkins/.
chown -R jenkins:dockergroup ~jenkins
chmod 600 ~jenkins/.ssh/id_rsa
