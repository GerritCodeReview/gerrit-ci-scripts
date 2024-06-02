#!/bin/bash -xe
cd gerrit
GJF_VERSION=$(grep -o "^VERSION=.*$" tools/setup_gjf.sh | grep -Eo "\d\.\d*(\.\d)?")
GJF="/home/jenkins/format/google-java-format-$GJF_VERSION"
if [ ! -f "$GJF" ]; then
  ./tools/setup_gjf.sh
  GJF=$(find 'tools/format' -name google-java-format-$GJF_VERSION)
fi
echo 'Running google-java-format check...'
git show --diff-filter=AM --name-only --pretty="" HEAD | grep java$ | xargs -r $GJF -n --set-exit-if-changed
