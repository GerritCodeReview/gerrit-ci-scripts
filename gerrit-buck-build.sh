rm -Rf buck-out
find plugins -type l -exec rm -f {} \;
yes | buck build -v 3 api api_install plugins:core release
cp buck-out/gen/release.war buck-out/gen/gerrit.war
