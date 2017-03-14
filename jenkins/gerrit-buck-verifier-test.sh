#!/bin/bash -e
set +x

if [ -f "gerrit/BUCK" ]
then
  cd gerrit

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  echo "Test with mode=$MODE"
  echo '----------------------------------------------'

  if [[ "$MODE" == *"reviewdb"* ]]
  then
    buck test --no-results-cache --exclude flaky
  fi

  if [[ "$MODE" == *"notedbPrimary"* ]]
  then
    export GERRIT_NOTEDB=PRIMARY
    buck test --no-results-cache --exclude flaky
  fi

  if [[ "$MODE" == *"disableChangeReviewDb"* ]]
  then
    export GERRIT_NOTEDB=DISABLE_CHANGE_REVIEW_DB
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
