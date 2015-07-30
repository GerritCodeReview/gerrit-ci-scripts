git checkout gerrit/{branch}
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}
rm -Rf buck-out
export BUCK_CLEAN_REPO_IF_DIRTY=y
buck build -v 3 plugins/{name}

