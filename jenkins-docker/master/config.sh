#!/bin/bash

if [ -f $JENKINS_HOME/config.xml ]
then
  CONFIG=$JENKINS_HOME/config.xml
else
  CONFIG=$JENKINS_REF/config.xml
fi

xsltproc \
  --stringparam use-security $USE_SECURITY \
  --stringparam oauth-client-id $OAUTH_ID \
  --stringparam oauth-client-secret $OAUTH_SECRET \
  --stringparam docker-url $DOCKER_HOST \
  $JENKINS_REF/edit-config.xslt $CONFIG > /tmp/config.xml.new
mv /tmp/config.xml.new $CONFIG

sed -i -e "s/user=.*/user=$JENKINS_API_USER/" /etc/jenkins_jobs/jenkins_jobs.ini
sed -i -e "s/password=.*/password=$JENKINS_API_PASSWORD/" /etc/jenkins_jobs/jenkins_jobs.ini

cp -R $JENKINS_REF/.ssh ~/.
chmod 600 ~/.ssh/id_rsa
