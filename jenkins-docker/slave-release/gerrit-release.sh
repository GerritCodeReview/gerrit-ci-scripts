#!/bin/bash -e

if [ "$1" == "" ] || [ "$2" == "" ]
then
  echo "Gerrit Code Review - release automation script"
  echo "----------------------------------------------"
  echo "Use: $0 <branch> <version> <next-version>"
  echo ""
  echo "Where: branch  Gerrit branch name where the release must be cut"
  echo "       version Gerrit semantic release number"
  echo "       next-version Next SNAPSHOT version after release"
  echo ""
  echo "Example: $0 stable-2.16 2.16.7 2.16.8-SNAPSHOT"
  exit 1
fi

export branch=$1
export version=$2
export nextversion=$3

if [ -d gerrit ]
then
  rm -Rf gerrit
fi

echo "Cloning and building Gerrit Code Review on branch $branch ..."
git clone https://gerrit.googlesource.com/gerrit && (cd gerrit && f=`git rev-parse --git-dir`/hooks/commit-msg ; curl -Lo $f https://gerrit-review.googlesource.com/tools/hooks/commit-msg ; chmod +x $f)

pushd gerrit

source set-java.sh 8

git checkout $branch
git fetch && git reset --hard origin/$branch
git submodule update --init

git clean -fdx
./tools/version.py $version
git commit -a -m "Set version to $version"
git push origin HEAD:refs/for/$branch

git tag -f -s -m "v$version" "v$version"
git submodule foreach 'if [ "$path" != "modules/jgit" ]; then git tag -f -s -m "v$version" "v$version"; fi'

bazelisk build release Documentation:searchfree
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

echo "Download the artifacts from SonaType staging repository at https://oss.sonatype.org"
echo "logging in using your credentials"

popd

cp -f gerrit/bazel-bin/Documentation/searchfree.zip .
cp -f gerrit/bazel-bin/release.war gerrit-$version.war

echo "gerrit.war checksums"
shasum gerrit-$version.war
shasum -a 256 gerrit-$version.war
md5sum gerrit-$version.war

echo "Pushing to Google Cloud Buckets"
gcloud auth login

echo "Pushing gerrit.war to gerrit-releases ..."
gsutil cp gerrit-$version.war gs://gerrit-releases/gerrit-$version.war

echo "Pushing gerrit documentation to gerrit-documentation ..."
unzip searchfree.zip
pushd Documentation
gsutil cp -r . gs://gerrit-documentation/Documentation/$version
popd

echo "Setting next version tag to $nextversion ..."
pushd gerrit
git clean -fdx
./tools/version.py $nextversion
git commit -a -m "Set version to $nextversion"
git push origin HEAD:refs/for/$branch
popd

echo "Release completed"
