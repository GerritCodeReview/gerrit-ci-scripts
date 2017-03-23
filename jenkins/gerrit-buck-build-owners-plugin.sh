#!/bin/bash -e

# NOTE: All Gerrit plugins currently depend on, at a minimum
# the bucklets repo, and most plugins don't build outside the
# Gerrit tree, even with bucklets.  As a result, we need to
# graft the plugin onto the Gerrit repo.  We do this by checking
# out the proper version of Gerrit, removing the plugin if it
# exists, then use git read-tree to put the plugin we're
# building in place.
git checkout -f gerrit/{branch}
git read-tree -u --prefix=plugins/owners-plugin origin/{branch}
cd plugins && ln -s owners-plugin/owners* . && cd ..
cat plugins/owners-plugin/.buckconfig >> .buckconfig

TARGETS=$(echo "{targets}" | sed -e 's/{{owners}}/owners/g')

. set-java.sh 8

buck build -v 3 $TARGETS

for JAR in $(find buck-out/gen/plugins/ -regex '.*/owners\(-autoassign\)*\.jar')
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    zip -d $JAR META-INF/services/com.fasterxml.jackson.core.JsonFactory
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=buck-out/gen/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > buck-out/gen/plugins/{name}/$(basename $JAR-version)
done
