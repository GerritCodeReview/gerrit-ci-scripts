#!/bin/bash -e

cd gerrit

git fetch origin $TARGET_BRANCH
git config user.name "Jenkins Build"
git config user.email "jenkins@gerritforge.com"
git merge --no-commit --no-edit --no-ff FETCH_HEAD
