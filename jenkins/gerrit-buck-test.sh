#!/bin/bash -e

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

rm -Rf plugins/*

echo 'Test in default DB mode'
echo '----------------------------------------------'
buck test --no-results-cache --num-threads 1 --exclude flaky

if [ "$HEAD_SHA1" != "$MASTER_SHA1" ]
then
  exit 0
fi

echo 'Test in Node DB mode'
echo '----------------------------------------------'
GERRIT_ENABLE_NOTEDB=TRUE buck test --num-threads 1 --no-results-cache --exclude flaky

echo 'PolyGerrit UX tests'
echo '----------------------------------------------'
buck test --include web

exit 0
