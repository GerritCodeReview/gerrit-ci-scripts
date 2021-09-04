#!/bin/bash

/usr/local/bin/config.sh
rm -Rf /var/jenkins_home/nodes

chown -R jenkins:dockergroup /var/jenkins_home
usermod -G docker jenkins

ALLOW_REMOTING_CLASSES=com.google.gerrit.extensions.common.AvatarInfo
JAVA_OPTS="-Dfile.encoding=UTF-8 -Dhudson.remoting.ClassFilter=$ALLOW_REMOTING_CLASSES"

gosu jenkins bash -c "JAVA_OPTS='$JAVA_OPTS' /usr/local/bin/run-jenkins.sh $*"
