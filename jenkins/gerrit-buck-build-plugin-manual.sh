# NOTE: All Gerrit plugins currently depend on, at a minimum
# the bucklets repo, and most plugins don't build outside the
# Gerrit tree, even with bucklets.  As a result, we need to
# graft the plugin onto the Gerrit repo.  We do this by checking
# out the proper version of Gerrit, removing the plugin if it
# exists, then use git read-tree to put the plugin we're
# building in place.
git checkout gerrit/{branch}
rm -rf plugins/{name}
git fetch https://gerrit.googlesource.com/plugins/{name} $REFS_CHANGE
git read-tree -u --prefix=plugins/{name} FETCH_HEAD

rm -Rf buck-out
export BUCK_CLEAN_REPO_IF_DIRTY=y
TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

buck build -v 3 $TARGETS

for JAR in $(buck targets --show_output $TARGETS | awk '{{print $2}}')
do
    PLUGIN_VERSION=$(git describe origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF

    DEST_JAR=buck-out/gen/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > buck-out/gen/plugins/{name}/$(basename $JAR-version)
done
