#!/bin/bash

/usr/local/bin/config.sh
rm -Rf /var/jenkins_home/nodes

chown -R jenkins:dockergroup /var/jenkins_home
usermod -G docker jenkins
gosu jenkins /usr/local/bin/run-jenkins.sh $*
