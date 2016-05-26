#!/bin/bash
sed -i -e "s/#JENKINS_API_USER#/$JENKINS_API_USER/g" /etc/jenkins_jobs/jenkins_jobs.ini
sed -i -e "s/#JENKINS_API_PASSWORD#/$JENKINS_API_PASSWORD/g" /etc/jenkins_jobs/jenkins_jobs.ini
