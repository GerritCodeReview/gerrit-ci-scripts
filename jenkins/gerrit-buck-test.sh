#!/bin/bash -e

function buckConfig {
  grep "$1" .buckconfig  | cut -d '=' -f 2 | tr -d '[[:space:]]'
}

SOURCE_LEVEL=$(buckConfig "source_level")
TARGET_LEVEL=$(buckConfig "target_level")
. set-java.sh $(( $SOURCE_LEVEL > $TARGET_LEVEL ? $SOURCE_LEVEL : $TARGET_LEVEL ))

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
