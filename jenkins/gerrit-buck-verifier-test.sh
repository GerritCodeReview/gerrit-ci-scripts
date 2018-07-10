#!/bin/bash -e
set +x

cd gerrit

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

echo "Test with mode=$MODE"
echo '----------------------------------------------'

if [[ "$MODE" == *"reviewdb"* ]]
then
  buck test --no-results-cache --exclude flaky
fi

