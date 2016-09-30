#!/bin/bash -ex

git checkout origin/{branch}
GITBLIT_TAG=$(expr "`grep com.gitblit lib/BUCK`" : '[^:]*:[^:]*:\([0-9\.]*\)')

git checkout gitblit/v$GITBLIT_TAG
ant -DresourceFolderPrefix=static installMaven
