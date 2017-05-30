set +x
rm -Rf buck-out
export BUCK_CLEAN_REPO_IF_DIRTY=y
git submodule update --init
buck build all
buck test
buck build //:install
