#!/bin/bash -e

if [ "$1" == "--help" ] || [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]
then
  echo "Gerrit Code Review - release automation script"
  echo "----------------------------------------------"
  echo "Use: $0 <branch> <version> <next-version> [<test-migration-version>]"
  echo ""
  echo "Where: branch  Gerrit branch name where the release must be cut"
  echo "       version Gerrit semantic release number"
  echo "       next-version Next SNAPSHOT version after release"
  echo "       test-migration-version Test migration from an earlier Gerrit version"
  echo ""
  echo "Example: $0 stable-3.10 3.10.2 3.10.3-SNAPSHOT 3.9.6"
  exit 1
fi

export branch=$1
export version=$2
export nextversion=$3
export migrationversion=$4

MAVEN_REPOSITORY="OSSRH-staging"
MAVEN_SETTINGS_FILE="$HOME/.m2/settings.xml"

bazel_config=""
if [ "$branch" == "stable-3.11" ]; then
  bazel_config="--config=java21"
fi

echo "Setting java version for $branch"
. set-java.sh --branch "$branch"

if [ -d gerrit ]
then
  rm -Rf gerrit
fi

if [ -f $HOME/.gitconfig.template ]
then
  cp $HOME/.gitconfig.template $HOME/.gitconfig
fi

if [ -f $HOME/.gitcookies ]
then
  echo "Configuring cookiefile..."
  git config --global http.cookiefile $HOME/.gitcookies
fi

if [ -f "$GPG_KEY" ]
then
  echo "Configuring GPG keys..."
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  echo "allow-loopback-pinentry" >> "$HOME/.gnupg/gpg-agent.conf"
  echo "use-agent" >> "$HOME/.gnupg/gpg.conf"
  echo "pinentry-mode loopback" >> "$HOME/.gnupg/gpg.conf"

  gpgconf --kill gpg-agent || true

  echo "Import private key..."
  gpg --batch --yes --import "$GPG_KEY"

  echo "Configuring git to read GPG passphrase from file..."
  git config --global gpg.program /usr/local/bin/gpg-loopback
fi

echo "Cloning and building Gerrit Code Review on branch $branch ..."
git config --global credential.helper cache
git clone https://gerrit.googlesource.com/gerrit && (cd gerrit && f=$(git rev-parse --git-dir)/hooks/commit-msg ; curl -Lo "$f" https://gerrit-review.googlesource.com/tools/hooks/commit-msg ; chmod +x "$f")

pushd gerrit

git checkout "$branch"
git fetch && git reset --hard origin/"$branch"
git submodule update --init

git clean -fdx
./tools/version.py "$version"
git commit -a -m 'Set version to '$version'

Release-Notes: skip'
git push origin HEAD:refs/for/"$branch"

git tag -f -s -m "v$version" "v$version"
git submodule foreach 'if [ "$path" != "modules/jgit" ]; then git tag -f -s -m "v$version" "v$version"; fi'

bazelisk build $bazel_config release Documentation:searchfree
./tools/maven/api.sh install $bazel_config

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

if test "$migrationversion" '!=' ""
then
  cp bazel-bin/release.war gerrit-$version.war
  $(dirname $0)/gerrit-upgrade-test.sh $migrationversion $version
fi

echo "Publishing Gerrit WAR and APIs to Maven Central ..."
export VERBOSE=1
./tools/maven/api.sh war_deploy $bazel_config
./tools/maven/api.sh deploy $bazel_config

echo "Extracting OSSRH credentials..."
ossrh_user=$(grep -A2 "<id>$MAVEN_REPOSITORY</id>" $MAVEN_SETTINGS_FILE | grep '<username>' | sed -E 's|.*<username>(.*)</username>.*|\1|')
ossrh_pass=$(grep -A2 "<id>$MAVEN_REPOSITORY</id>" $MAVEN_SETTINGS_FILE | grep '<password>' | sed -E 's|.*<password>(.*)</password>.*|\1|')

if [ -z "$ossrh_user" ] || [ -z "$ossrh_pass" ]; then
  echo "Failed to extract credentials from $MAVEN_SETTINGS_FILE"
  exit 3
fi

bearer_token=$(echo -n "$ossrh_user:$ossrh_pass" | base64)

# Manually upload to Maven Central
# https://central.sonatype.org/publish/publish-portal-ossrh-staging-api/#post-to-manualuploaddefaultrepositorynamespace
curl -X POST \
  'https://ossrh-staging-api.central.sonatype.com/manual/upload/defaultRepository/com.google.gerrit' \
  -H 'accept: */*' \
  -H "Authorization: Bearer $bearer_token" \
  -d "''" || {
    echo "manual upload endpoint failed. Aborting release."
    exit 4
  }

echo "Download the artifacts from SonaType staging repository at https://oss.sonatype.org"
echo "logging in using your credentials"

popd

cp -f gerrit/bazel-bin/Documentation/searchfree.zip .
cp -f gerrit/bazel-bin/release.war gerrit-"$version".war

echo "gerrit.war checksums"
shasum gerrit-"$version".war
shasum -a 256 gerrit-"$version".war
md5sum gerrit-"$version".war

echo "Pushing to Google Cloud Buckets"
gcloud auth login

echo "Pushing gerrit.war to gerrit-releases ..."
gsutil cp gerrit-"$version".war gs://gerrit-releases/gerrit-"$version".war

echo "Pushing gerrit documentation to gerrit-documentation ..."
unzip searchfree.zip
pushd Documentation
version_no_rc=$(echo "$version" | cut -d '-' -f 1)
gsutil cp -r . gs://gerrit-documentation/Documentation/"$version_no_rc"
popd

echo "Setting next version tag to $nextversion ..."
pushd gerrit
git clean -fdx
./tools/version.py "$nextversion"
git commit -a -m 'Set version to '$nextversion'

Release-Notes: skip'
git push origin HEAD:refs/for/"$branch"
popd

echo "Release completed"
