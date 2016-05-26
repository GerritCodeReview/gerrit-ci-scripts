#!/bin/bash
xsltproc \
  --stringparam use-security true \
  --stringparam oauth-client-id clientid \
  --stringparam oauth-client-secret secret \
  ./edit-config.xslt config.xml

sed -i -e "s/#OAUTH_ID#/$OAUTH_ID/g" $JENKINS_REF/config.xml
sed -i -e "s/#OAUTH_SECRET#/$OAUTH_SECRET/g" $JENKINS_REF/config.xml

sed -i -e "s/#JENKINS_API_USER#/$JENKINS_API_USER/g" /etc/jenkins_jobs/jenkins_jobs.ini
sed -i -e "s/#JENKINS_API_PASSWORD#/$JENKINS_API_PASSWORD/g" /etc/jenkins_jobs/jenkins_jobs.ini
