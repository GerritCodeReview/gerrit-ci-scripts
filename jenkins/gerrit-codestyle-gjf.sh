#!/bin/bash -xe
#
# Copyright (C) 2024 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

NEW_GJF_SH=./tools/gjf.sh
OLD_SETUP_GJF_SH=./tools/setup_gjf.sh

cd gerrit

if  [ -f "$NEW_GJF_SH" ]; then
  echo "Using new \"$NEW_GJF_SH\"."
  GJF_VERSION=$($NEW_GJF_SH default-version)
  GJF="/home/jenkins/format/google-java-format-$GJF_VERSION"
  if [ ! -f "$GJF" ]; then
    $NEW_GJF_SH setup
    GJF="tools/format/google-java-format-$GJF_VERSION"
  fi
else
  echo "Using old \"$OLD_SETUP_GJF_SH\"."
  GJF_VERSION=$(grep -o "^VERSION=.*$" $OLD_SETUP_GJF_SH | grep -o '[0-9][0-9]*\.[0-9][0-9]*[\.0-9]*')
  GJF="/home/jenkins/format/google-java-format-$GJF_VERSION"
  if [ ! -f "$GJF" ]; then
    $OLD_SETUP_GJF_SH
    GJF=$(find 'tools/format' -regex '.*/google-java-format-[0-9][0-9]*\.[0-9][0-9]*[\.0-9]*')
  fi
fi

echo 'Running google-java-format check...'
git show --diff-filter=AM --name-only --pretty="" HEAD | grep java$ | xargs -r $GJF -n --set-exit-if-changed
