#!/bin/bash -e
cd gerrit
GJF_VERSION=$(grep -o "^VERSION=.*$" tools/setup_gjf.sh | grep -o "[0-9][0-9]*\.[0-9][0-9]*")
GJF="/home/jenkins/format/google-java-format-$GJF_VERSION"
if [ ! -f "$GJF" ]; then
  ./tools/setup_gjf.sh
  GJF=$(find 'tools/format' -regex '.*/google-java-format-[0-9][0-9]*\.[0-9][0-9]*')
fi

echo ""
echo "==============================================================="
echo "Running google-java-format check ...                           "
echo "---------------------------------------------------------------"
O=$(git show --diff-filter=AM --name-only --pretty="" HEAD | grep java$ | xargs -r $GJF -n --set-exit-if-changed) || printf "The following files are not properly formatted:\n$O"
