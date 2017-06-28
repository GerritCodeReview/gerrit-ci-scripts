#!/bin/bash -e

cd gerrit

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

echo 'Test in default DB mode'
echo '----------------------------------------------'
buck test --all --exclude slow
