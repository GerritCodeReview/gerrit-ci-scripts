#!/bin/bash -e

MASTER_SHA1=$(git rev-parse origin/master)
HEAD_SHA1=$(git rev-parse HEAD)

if [ "$HEAD_SHA1" == "$MASTER_SHA1" ]
then
  . set-java.sh 8
else
  . set-java.sh 7
fi

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
