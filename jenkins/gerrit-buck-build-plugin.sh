# NOTE: All Gerrit plugins currently depend on, at a minimum
# the bucklets repo, and most plugins don't build outside the
# Gerrit tree, even with bucklets.  As a result, we need to
# graft the plugin onto the Gerrit repo.  We do this by checking
# out the proper version of Gerrit, removing the plugin if it
# exists, then use git read-tree to put the plugin we're
# building in place.
git checkout gerrit/{branch}
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}

rm -Rf buck-out
export BUCK_CLEAN_REPO_IF_DIRTY=y

for target in "{targets}"
do
  buck build -v 3 $target
  JAR=$(buck targets --show_output $target | awk '{{print $2}}')
  jar xf $JAR META-INF/MANIFEST.MF
  PLUGIN_VERSION=$(grep "Implementation-Version" META-INF/MANIFEST.MF | cut -d ' ' -f 2)
  echo "$PLUGIN_VERSION" > $JAR-version
done
