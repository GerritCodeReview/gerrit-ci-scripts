#!/bin/bash -e

if [ -f "gerrit/BUCK" ]
then
  cd gerrit

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  echo 'Test in default DB mode'
  echo '----------------------------------------------'
  buck test --no-results-cache --exclude flaky

  if [ "{branch}"!="master" ]
  then
    exit 0
  fi

  echo 'Test in Node DB mode'
  echo '----------------------------------------------'
  export GERRIT_NOTEDB=READ_WRITE
  buck test --no-results-cache --exclude flaky

  if [ ! -d polygerrit-ui ]
  then
    exit 0
  fi

  echo 'PolyGerrit UX tests (on Java8)'
  echo '----------------------------------------------'
  . set-java.sh 8
  buck test --include web
fi

exit 0
