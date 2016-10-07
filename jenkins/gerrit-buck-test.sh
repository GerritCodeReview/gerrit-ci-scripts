#!/bin/bash -e

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

rm -Rf plugins/*

echo 'Test in default DB mode'
echo '----------------------------------------------'
buck test --no-results-cache --exclude flaky

if [ ! -d gerrit-server/src/main/java/com/google/gerrit/server/notedb ]
then
  exit 0
fi

echo 'Test in Node DB mode'
echo '----------------------------------------------'
GERRIT_ENABLE_NOTEDB=TRUE buck test --no-results-cache --exclude flaky

if [ ! -d polygerrit-ui ]
then
  exit 0
fi

echo 'PolyGerrit UX tests'
echo '----------------------------------------------'
buck test --include web

exit 0
