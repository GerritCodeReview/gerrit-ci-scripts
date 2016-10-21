#!/bin/bash

if [ "$1" == "" ]
then
  echo "Set current Buck/Java version level"
  echo ""
  echo "Use: $0 <7|8>"
  exit 1
fi

export PATH=/opt/buck-java$1/bin:$PATH
