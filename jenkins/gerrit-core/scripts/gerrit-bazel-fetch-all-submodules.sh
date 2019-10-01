#!/bin/bash -e
set +x
cd gerrit
function fetch_submodules {
  # We do need to call update even if we know it will fail: the submodules git needs
  # to be initialised and made it pointing to the correct remote submodule URL
  git submodule update > /dev/null 2> /dev/null || true
  export SUBMODULES=$(git submodule status | awk '{print $2}')
  for module in $SUBMODULES
  do
    echo "Fetching all changes refs for $module ..."
    pushd $module > /dev/null
    git fetch -q origin +refs/changes/*:refs/changes/*
    popd > /dev/null
  done
}
git submodule init
# Fetch submodules refs/changes as fallback action of a submodule update failure
echo "Updating all submodules ..."
git submodule update || ( fetch_submodules && git submodule update )
