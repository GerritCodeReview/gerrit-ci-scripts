#!/bin/bash -e
set +x

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

  echo "Test with mode=$MODE"
  echo '----------------------------------------------'

  if [[ "$MODE" == *"reviewdb"* ]]
  then
    runTests
  fi

  if [[ "$MODE" == *"notedbReadWrite"* ]]
  then
    export GERRIT_NOTEDB=READ_WRITE
    runTests
  fi

  if [[ "$MODE" == *"polygerrit"* ]]
  then
    if [ -z "$DISPLAY" ]
    then
      echo 'Not running local tests because env var "DISPLAY" is not set.'
    else
      echo 'Running local tests...'
      buck test --include web
    fi
    if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
    then
      echo 'Not running on Sauce Labs because env vars are not set.'
    else
      echo 'Running tests on Sauce Labs...'
      WCT_ARGS='--plugin sauce' buck test --no-results-cache --include web
    fi
  fi
fi
