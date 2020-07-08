#!/bin/bash -e

if [ -f ~/polygerrit-failed ]
then
   echo ""
   echo "*** POLYGERRIT TEST FAILED ***"
   echo "See test log below"
   echo "=============================="
   echo ""
   find ~/.cache/bazel/_bazel_jenkins -name test.log | xargs cat
   exit -1
fi

