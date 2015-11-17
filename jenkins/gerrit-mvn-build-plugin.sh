find . -type d -name 'target' -delete
mvn package

# Extract version information
PLUGIN_JAR=$(ls target/{name}*jar)
jar xf $PLUGIN_JAR META-INF/MANIFEST.MF
PLUGIN_VERSION=$(grep "Implementation-Version" META-INF/MANIFEST.MF | cut -d ' ' -f 2)

echo "$PLUGIN_VERSION" > $PLUGIN_JAR-version
