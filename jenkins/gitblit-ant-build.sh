#!/bin/bash -ex

git checkout origin/{branch}
GITBLIT_TAG=$(expr "`grep com.gitblit lib/BUCK`" : '[^:]*:[^:]*:\([0-9\.]*\)')

git fetch gitblit refs/tags/v$GITBLIT_TAG && git checkout FETCH_HEAD
ant -DresourceFolderPrefix=static installMaven
