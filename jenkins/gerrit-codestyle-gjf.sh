#!/bin/bash -xe
cd gerrit
GJF_VERSION=$(./tools/gjf.sh default-version)
GJF="/home/jenkins/format/google-java-format-$GJF_VERSION"
if [ ! -f "$GJF" ]; then
  ./tools/gjf.sh setup
  GJF="tools/format/google-java-format-$GJF_VERSION"
fi
echo 'Running google-java-format check...'
git show --diff-filter=AM --name-only --pretty="" HEAD | grep java$ | xargs -r $GJF -n --set-exit-if-changed
