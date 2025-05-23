#!/bin/bash -e

if [ -f ~/polygerrit-failed ]
then
   echo ""
   echo "*** POLYGERRIT TEST FAILED ***"
   echo "See test log below"
   echo "=============================="
   echo ""
   if [ -f gerrit/polygerrit-ui/web_test_runner.sh ]
   then
     cat $(ls ~/.cache/bazel/_bazel_jenkins/*/execroot/gerrit/bazel-out/*/testlogs/polygerrit-ui/web_test_runner/test.log)
   elif [ -f gerrit/polygerrit-ui/karma_test.sh ]
   then
     cat $(ls ~/.cache/bazel/_bazel_jenkins/*/execroot/gerrit/bazel-out/*/testlogs/polygerrit-ui/karma_test/test.log)
   else
     cat $(ls ~/.cache/bazel/_bazel_jenkins/*/execroot/gerrit/bazel-out/*/testlogs/polygerrit-ui/app/wct_test/test.log)
   fi
   exit -1
fi

