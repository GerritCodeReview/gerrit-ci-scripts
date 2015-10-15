rm -Rf buck-out
find plugins -type l -exec rm -f {} \;
export BUCK_CLEAN_REPO_IF_DIRTY=y
buck build -v 3 api api_install plugins:core release
cp buck-out/gen/release/release.war buck-out/gen/release/gerrit.war
