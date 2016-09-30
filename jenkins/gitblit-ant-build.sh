#!/bin/bash -ex

GITBLIT_TAG=$(expr "`grep com.gitblit gitblit/lib/BUCK`" : '[^:]*:[^:]*:\([0-9\.]*\)')
cd github/gitblit
git checkout v$GITBLIT_TAG
ant -DresourceFolderPrefix=static installMaven
