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
    stable-3.10)
      JAVA_VERSION=17
      ;;

    *)
      JAVA_VERSION=21
      ;;
  esac
else
  JAVA_VERSION=$1
fi

export JAVA_HOME=/usr/lib/jvm/temurin-$JAVA_VERSION-jdk-amd64
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH

echo "Java set to: $(which java)"
