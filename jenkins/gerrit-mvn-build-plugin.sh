find . -type d -name 'target' -delete
mvn package

# Extract version information
PLUGIN_JARS=$(find . -name '{repo}*jar')
for jar in $PLUGIN_JARS
do
  jar xf $jar META-INF/MANIFEST.MF
  PLUGIN_VERSION=$(grep "Implementation-Version" META-INF/MANIFEST.MF | cut -d ' ' -f 2)

  echo "$PLUGIN_VERSION" > $jar-version
done
