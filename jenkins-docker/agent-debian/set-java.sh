#!/bin/bash

if [ "$1" == "" ]
then
  echo "Set current Java version level"
  echo ""
  echo "Use: $0 <7|8>"
  exit 1
fi

export JAVA_HOME=/usr/lib/jvm/java-$1-openjdk-amd64
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH

echo "Java set to: $(which java)"

