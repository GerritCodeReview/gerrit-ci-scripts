rm -Rf buck-out
find plugins -type l -exec rm -f {} \;
export BUCK_CLEAN_REPO_IF_DIRTY=y
buck build -v 3 api api_install plugins:core release
mv $(buck targets --show-output release | awk '{print $2}') buck-out/gen/gerrit.war
