#!/bin/bash

if [ "$1" == "" ]
then
  echo "Set current Java version level"
  echo ""
  echo "Use    : $0 [<version number> | --branch <branch name>]"
  echo "Example: $0 17"
  echo "         Java set to: /usr/lib/jvm/temurin-17-jdk-amd64/bin/java"
  echo "Providing --branch automatically selects the java version"
  echo "Example: $0 --branch stable-3.11"
  echo "         Java set to: /usr/lib/jvm/temurin-21-jdk-amd64/bin/java"
  exit 1
fi

if [ "$1" == "--branch" ]
then
  shift
  case "$1" in
    master|stable-3.11|stable-3.12|stable-3.13)
      JAVA_VERSION=21
      ;;

    stable-3.9|stable-3.10)
      JAVA_VERSION=17
      ;;

    *)
      JAVA_VERSION=11
      ;;
  esac
else
  JAVA_VERSION=$1
fi

export JAVA_HOME=/usr/lib/jvm/temurin-$JAVA_VERSION-jdk-amd64
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH

echo "Java set to: $(which java)"

if [ "$JAVA_VERSION" == "11" ] || [ "$JAVA_VERSION" == "17" ] || \
    [ "$JAVA_VERSION" == "21" ]
then
  # See Bazel Issue 3236 with Java 11/17/21 [https://github.com/bazelbuild/bazel/issues/3236]
  export BAZEL_OPTS="$BAZEL_OPTS --sandbox_tmpfs_path=/tmp"
fi

