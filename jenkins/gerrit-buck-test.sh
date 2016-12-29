#!/bin/bash -e

function runTests {
  echo ''
  echo 'Running slow tests serialized ...'
  echo ''
  buck test --no-results-cache --labels slow -j 1
  echo ''
  echo 'Running fast tests in parallel ...'
  buck test --no-results-cache --exclude flaky slow -j 3
  echo ''  
}

if [ -f "gerrit/BUCK" ]
then
  cd gerrit

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  echo 'Test in default DB mode'
  echo '----------------------------------------------'
  runTests

  if [ ! -d gerrit-server/src/main/java/com/google/gerrit/server/notedb ]
  then
    exit 0
  fi

  echo 'Test in Node DB mode'
  echo '----------------------------------------------'
  export GERRIT_NOTEDB=READ_WRITE
  runTests

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
