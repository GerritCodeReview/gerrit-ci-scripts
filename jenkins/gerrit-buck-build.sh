rm -Rf buck-out
find plugins -type l -exec rm -f {} \;
export BUCK_CLEAN_REPO_IF_DIRTY=y
buck build -v 3 api api_install plugins:core release
find buck-out/gen -name 'release.war' -exec mv {} $(dirname {})/gerrit.war \;
