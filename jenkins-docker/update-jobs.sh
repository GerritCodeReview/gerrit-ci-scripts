#!/bin/sh

if [ -e ~/gerrit-ci-scripts ] && [ ! -e ~/gerrit-ci-scripts/TESTING ]; then
    cd ~/gerrit-ci-scripts && git pull --rebase
elif [ ! -e ~/gerrit-ci-scripts/TESTING ]; then
    git clone https://gerrit.googlesource.com/gerrit-ci-scripts ~/gerrit-ci-scripts
fi

jenkins-jobs update ~/gerrit-ci-scripts/jenkins/
