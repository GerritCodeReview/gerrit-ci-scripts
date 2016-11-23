#!/bin/bash -e

# NOTE: All Gerrit plugins currently depend on, at a minimum
# the bucklets repo, and most plugins don't build outside the
# Gerrit tree, even with bucklets.  As a result, we need to
# graft the plugin onto the Gerrit repo.  We do this by checking
# out the proper version of Gerrit, removing the plugin if it
# exists, then use git read-tree to put the plugin we're
# building in place.
if [ -f 'gerrit/BUCK' ]
then
  git checkout gerrit/{branch}
  rm -rf plugins/its-{name}
  rm -rf plugins/its-base
  git read-tree -u --prefix=plugins/its-{name} origin/{branch}
  git read-tree -u --prefix=plugins/its-base base/{branch}

  rm -Rf buck-out

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  buck build -v 3 plugins/its-{name}

  # Remove duplicate entries
  PLUGIN_JAR=$(ls $(pwd)/buck-out/gen/plugins/its-{name}/its-{name}*.jar)
  mkdir jar-out && pushd jar-out
  jar xf $PLUGIN_JAR && jar cmf META-INF/MANIFEST.MF $PLUGIN_JAR .
  popd

  # Extract version information
  PLUGIN_VERSION=$(git describe --always origin/{branch})
  echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
  jar ufm $PLUGIN_JAR MANIFEST.MF && rm MANIFEST.MF

  echo "$PLUGIN_VERSION" > $PLUGIN_JAR-version
fi
