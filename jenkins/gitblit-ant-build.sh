#!/bin/bash -ex

git checkout origin/{branch}
if [ -f BUILD ]
then
  GITBLIT_LINE=$(grep com.gitblit external_plugin_deps.bzl)
  if expr "$GITBLIT_LINE" : '.*[0-9\.]*-SNAPSHOT.*'
  then
    GITBLIT_REF=ref/heads/master
  else
    GITBLIT_REF=ref/tags/v$(expr "$GITBLIT_LINE" : '[^:]*:[^:]*:\([0-9\.]*\)')
  fi
else
  GITBLIT_REF=ref/tags/v$(expr "`grep com.gitblit lib/BUCK`" : '[^:]*:[^:]*:\([0-9\.]*\)')
fi

git fetch gitblit $GITBLIT_REF && git checkout FETCH_HEAD

# Apply PR#1168 for Lucene compatibility with Gerrit master
if [ "$GITBLIT_REF" == "ref/heads/master" ]
then
  git config user.name "Gerrit CI"
  git config user.email "jenkins@gerritforge.com"
  git fetch gitblit refs/pull/1168/head && git merge --no-edit FETCH_HEAD
fi

ant -DresourceFolderPrefix=static installMaven
