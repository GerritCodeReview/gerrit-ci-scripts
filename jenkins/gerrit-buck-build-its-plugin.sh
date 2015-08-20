# NOTE: All Gerrit plugins currently depend on, at a minimum
# the bucklets repo, and most plugins don't build outside the
# Gerrit tree, even with bucklets.  As a result, we need to
# graft the plugin onto the Gerrit repo.  We do this by checking
# out the proper version of Gerrit, removing the plugin if it
# exists, then use git read-tree to put the plugin we're
# building in place.  
git checkout gerrit/{branch}
rm -rf plugins/its-{name}
git read-tree -u --prefix=plugins/its-{name} origin/{branch}
git read-tree -u --prefix=plugins/its-base base/{branch}

rm -Rf buck-out
export BUCK_CLEAN_REPO_IF_DIRTY=y
buck build -v 3 plugins/its-base
buck build -v 3 plugins/its-{name}

