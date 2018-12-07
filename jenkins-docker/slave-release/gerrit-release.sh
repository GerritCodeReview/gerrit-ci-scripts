#!/bin/bash -e

if [ "$1" == "" ] || [ "$2" == "" ]
then
  echo "Gerrit Code Review - release automation script"
  echo "----------------------------------------------"
  echo "Use: $0 <branch> <version>"
  echo ""
  echo "Where: branch  Gerrit branch name where the release must be cut"
  echo "       version Gerrit semantic release number"
  echo ""
  echo "Example: $0 stable-2.16 2.16.1"
  exit 1
fi

export branch=$1
export version=$2

if [ -d gerrit ]
then
  rm -Rf gerrit
fi

echo "Cloning and building Gerrit Code Review on branch $branch ..."
git clone https://gerrit.googlesource.com/gerrit
pushd gerrit

source set-java.sh 8

git checkout $branch
git fetch && git reset --hard origin/$branch
git submodule update --init

git clean -fdx
./tools/version.py $version
git commit -a -m "Set version to $version"
git tag -f -s -m "v$version" "v$version"
git submodule foreach git tag -f -s -m "v$version" "v$version"

bazel build release Documentation:searchfree
./tools/maven/api.sh install

echo -n "Checking Gerrit version ... "

warVersion=$(java -jar bazel-bin/release.war --version)

if ! [ "$warVersion" == "gerrit version $version" ]
then
  echo "Version build is $warVersion but was expecting $version"
  exit 2
fi

echo "OK"

echo "Checking Gerrit plugins version ... "
java -jar bazel-bin/release.war init --list-plugins

echo "Publishing Gerrit WAR and APIs to Maven Central ..."
export VERBOSE=1
./tools/maven/api.sh war_deploy
./tools/maven/api.sh deploy

echo "Release completed"
echo "Download the artifacts from SonaType staging repository at https://oss.sonatype.org"
echo "logging in using your credentials"
