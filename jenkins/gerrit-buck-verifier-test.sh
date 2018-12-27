#!/bin/bash -e
set +x

cd gerrit

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

echo "Test with mode=$MODE"
echo '----------------------------------------------'

BUCK_OPTIONS="--no-results-cache"
if ([ "$TARGET_BRANCH" == "stable-2.9" ])
then
  BUCK_OPTIONS="--all"
fi

if [[ "$MODE" == *"reviewdb"* ]]
then
  buck test $BUCK_OPTIONS --exclude flaky
fi

