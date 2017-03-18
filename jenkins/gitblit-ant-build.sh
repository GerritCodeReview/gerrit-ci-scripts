#!/bin/bash -ex

git checkout origin/{branch}
if [ -f BUILD ]
then
  GITBLIT_LINE=$(grep com.gitblit external_plugin_deps.bzl)
  if expr "$GITBLIT_LINE" : '.*[0-9\.]*-SNAPSHOT.*'
  then
    GITBLIT_REF=refs/heads/master
  else
    GITBLIT_REF=refs/tags/v$(expr "$GITBLIT_LINE" : '[^:]*:[^:]*:\([0-9\.]*\)')
  fi
else
  GITBLIT_REF=refs/tags/v$(expr "`grep com.gitblit lib/BUCK`" : '[^:]*:[^:]*:\([0-9\.]*\)')
fi

git fetch gitblit $GITBLIT_REF && git checkout FETCH_HEAD
ant -DresourceFolderPrefix=static installMaven
