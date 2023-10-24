#!/bin/bash -e

case {branch} in
  master|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

git checkout {branch}

java -fullversion
bazelisk version
bazelisk build all
