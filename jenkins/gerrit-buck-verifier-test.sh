#!/bin/bash -e
set +x

if [ -f "gerrit/BUCK" ]
then
  cd gerrit

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')
  export GERRIT_USE_SSH=NO

  echo "Test with mode=$MODE"
  echo '----------------------------------------------'

  if [[ "$MODE" == *"reviewdb"* ]]
  then
    buck test --no-results-cache --exclude flaky
  fi

  if [[ "$MODE" == *"notedbReadWrite"* ]]
  then
    export GERRIT_NOTEDB=READ_WRITE
    buck test --no-results-cache --exclude flaky
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
