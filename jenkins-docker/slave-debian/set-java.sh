#!/bin/bash

usage() {
    me=`set-java "$0"`
    echo >&2 "Usage: $me [--toolchain TOOLCHAIN] [JAVA_VER]"
    exit 1
}

while test $# -gt 0 ; do
  case "$1" in
  --toolchain)
    shift
    TOOLCHAIN=$1
    shift
    ;;

  *)
    break
  esac
done

test -z "$TOOLCHAIN" && TOOLCHAIN=8

export JAVA_HOME=/usr/lib/jvm/java-$1-openjdk-amd64
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH

echo "Java set to: $(which java)"

if test $TOOLCHAIN -ne 8; then
  export BAZEL_OPTS="--host_javabase=@bazel_tools//tools/jdk:remote_jdk$TOOLCHAIN \
    --javabase=@bazel_tools//tools/jdk:remote_jdk$TOOLCHAIN \
    --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_java$TOOLCHAIN \
    --java_toolchain=@bazel_tools//tools/jdk:toolchain_java$TOOLCHAIN"

  echo "Set Java toolchain $TOOLCHAIN"
fi
