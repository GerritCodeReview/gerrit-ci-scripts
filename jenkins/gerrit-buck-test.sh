#!/bin/bash -e

cd gerrit

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

BUCK_OPTIONS="--no-results-cache"
if ([ "$TARGET_BRANCH" == "stable-2.9" ])
then
  BUCK_OPTIONS=""
fi

echo 'Test in default DB mode'
echo '----------------------------------------------'
buck test $BUCK_OPTIONS --exclude flaky
