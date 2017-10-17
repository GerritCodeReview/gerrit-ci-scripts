#!/bin/bash -e

if [ -f "gerrit/BUCK" ]
then
  cd gerrit

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  echo 'Test in default DB mode'
  echo '----------------------------------------------'
  buck test --no-results-cache --exclude flaky

  if [ ! -d gerrit-server/src/main/java/com/google/gerrit/server/notedb ]
  then
    exit 0
  fi
fi

exit 0
