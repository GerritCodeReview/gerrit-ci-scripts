rm -Rf buck-out
find plugins -type l -exec rm -f {} \;
export BUCK_CLEAN_REPO_IF_DIRTY=y
buck build -v 3 api api_install plugins:core release
export WAR=$(find buck-out/gen -name 'release.war')
mv $WAR $(dirname $WAR)/gerrit.war
