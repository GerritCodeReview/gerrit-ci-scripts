#!/bin/bash -ex

git checkout origin/{branch}
if [ -f BUILD ]
then
  GITBLIT_LINE=$(grep com.gitblit external_plugin_deps.bzl)
  if expr "$GITBLIT_LINE" : '.*[0-9\.]*-SNAPSHOT.*'
  then
    GITBLIT_TAG=ref/heads/master
  else
    GITBLIT_TAG=ref/tags/v$(expr "$GITBLIT_LINE" : '[^:]*:[^:]*:\([0-9\.]*\)')
  fi
else
  GITBLIT_TAG=ref/tags/v$(expr "`grep com.gitblit lib/BUCK`" : '[^:]*:[^:]*:\([0-9\.]*\)')
fi

git fetch gitblit refs/tags/v$GITBLIT_TAG && git checkout FETCH_HEAD

# Apply PR#1168 for Lucene compatibility with Gerrit master
if [ "$GITBLIT_TAG" == "refs/heads/master" ]
then
  git fetch gitblit refs/pull/1168/head && git cherry-pick FETCH_HEAD
fi

ant -DresourceFolderPrefix=static installMaven
