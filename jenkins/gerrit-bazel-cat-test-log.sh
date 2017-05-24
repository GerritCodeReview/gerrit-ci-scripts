#!/bin/bash -e

if [ -f ~/polygerrit-failed ]
then
   echo ""
   echo "*** POLYGERRIT TEST FAILED ***"
   echo "See test log below"
   echo "=============================="
   echo ""
   cat $(ls ~/.cache/bazel/_bazel_jenkins/*/execroot/gerrit/bazel-out/local-fastbuild/testlogs/polygerrit-ui/app/wct_test/test.log 2>/dev/null)
   exit -1
fi

