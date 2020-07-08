#!/bin/bash -e

if [ -f ~/polygerrit-failed ]
then
   echo ""
   echo "*** POLYGERRIT TEST FAILED ***"
   echo "See test log below"
   echo "=============================="
   echo ""
   cat $(find ~/.cache/bazel/_bazel_jenkins -name test.log)
   exit -1
fi

