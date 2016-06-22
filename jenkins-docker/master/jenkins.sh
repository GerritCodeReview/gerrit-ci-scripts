#!/bin/bash

/usr/local/bin/config.sh
rm -Rf /var/jenkins_home/nodes
/usr/local/bin/run-jenkins.sh $*
