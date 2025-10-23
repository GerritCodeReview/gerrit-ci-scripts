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
  echo ""
  echo "Environment variables:"
  echo "* GCLOUD_AUTH_TOKEN:"
  echo "     OAuth2 access token, used to upload artifacts and documentation to gcloud"
  echo "* GPG_KEY:"
  echo "     GPG key to be imported for signing"
  echo "* GPG_PASSPHRASE:"
  echo "     GPG passphrase"
  echo "* GS_GIT_USER:"
  echo "     Username for git operations targeting gerrit.googlesource.com"
  echo "* GS_GIT_PASS:"
  echo "     Password for git operations targeting gerrit.googlesource.com"
  echo "* MAVENCENTRAL_USERNAME:"
  echo "     Username used to upload artifacts to Maven Central"
  echo "* MAVENCENTRAL_TOKEN:"
  echo "     API Token used to upload artifacts to Maven Central"
  echo "* DRY_RUN:"
  echo "     When set to 'true' or 'TRUE', dry-run of the release process, without pushing changes or tags"
  echo ""
  exit 1
fi

export branch=$1
export version=$2
export nextversion=$3
export migrationversion=$4

export CLOUDSDK_AUTH_ACCESS_TOKEN="$GCLOUD_AUTH_TOKEN"

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

echo "Installing git credentials..."
echo "machine gerrit.googlesource.com login $GS_GIT_USER password $GS_GIT_PASS" > "$HOME/.netrc"
chmod 600 "$HOME/.netrc"

if [ -n "$GPG_KEY" ]
then
  echo "Configuring GPG keys..."
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  echo "allow-loopback-pinentry" >> "$HOME/.gnupg/gpg-agent.conf"
  echo "use-agent" >> "$HOME/.gnupg/gpg.conf"
  echo "pinentry-mode loopback" >> "$HOME/.gnupg/gpg.conf"

  gpgconf --kill gpg-agent || true

  echo "Import private key..."

  # The use of 'envsubst' allows to avoid the accidental display of the GPG key in the output
  echo '$GPG_KEY' | envsubst '$GPG_KEY' > "/tmp/gpg-key"
  gpg --batch --yes --import /tmp/gpg-key && rm -f /tmp/gpg-key

  echo "Configuring git to read GPG passphrase from file..."
  export GPG_PASSPHRASE_FILE="$HOME/.gnupg/gpg-passphrase"
  echo '$GPG_PASSPHRASE' | envsubst '$GPG_PASSPHRASE' > $GPG_PASSPHRASE_FILE
  git config --global gpg.program /usr/local/bin/gpg-loopback


  echo "Testing if GPG signature works"
  echo foo > /tmp/foo
  /usr/local/bin/gpg-loopback --sign /tmp/foo && /usr/local/bin/gpg-loopback --verify /tmp/foo.gpg
fi

GPG_USER=$(gpg -K --with-colons | grep uid | cut -d ':' -f 10)
git config --global user.name "$(echo "$GPG_USER" | awk '{print $1" "$2}')"
git config --global user.email $(echo "$GPG_USER" | sed 's/.*<//' | sed 's/>//')

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
test $DRY_RUN = true || test $DRY_RUN = TRUE || git push origin HEAD:refs/for/"$branch"

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

isOldStyleMaven=true
grep -q "gpg:sign-and-deploy-file" tools/maven/mvn.py || isOldStyleMaven=false

if [[ "$isOldStyleMaven" == "true" ]]
then
  echo "LEGACY deployment - Installing maven credentials"
  mkdir -p "$HOME/.m2"
  # shellcheck disable=SC2016
  envsubst '$MAVENCENTRAL_USERNAME $MAVENCENTRAL_TOKEN' < /tmp/m2.settings.xml.template > "$HOME/.m2/settings.xml"
else
  echo "NEW deployment - Setting up JReleaser environment"
  export JRELEASER_MAVENCENTRAL_USERNAME="$MAVENCENTRAL_USERNAME"
  export JRELEASER_MAVENCENTRAL_TOKEN="$MAVENCENTRAL_TOKEN"
  export GPG_KEY_ID=$(gpg --list-keys --with-colons | grep -A1 '^pub:' | grep fpr | cut -d':' -f10)
  export JRELEASER_GPG_PUBLIC_KEY=$(gpg-loopback --armor --export $GPG_KEY_ID)
  export JRELEASER_GPG_SECRET_KEY=$(gpg-loopback --armor --export-secret-key $GPG_KEY_ID)
  export JRELEASER_GPG_PASSPHRASE="$GPG_PASSPHRASE"
fi

echo "Publishing Gerrit WAR and APIs to Maven Central ..."
export VERBOSE=1
./tools/maven/api.sh war_deploy $bazel_config || {
  echo "****** WAR DEPLOYMENT FAILURE ******"
  test $isOldStyleMaven = "true" || cat ./tools/maven-central/out/jreleaser/trace.log
  exit 1
}

./tools/maven/api.sh deploy $bazel_config || {
  echo "****** API DEPLOYMENT FAILURE ******"
  test $isOldStyleMaven = "true" || cat ./tools/maven-central/out/jreleaser/trace.log
  exit 1
}

if [[ "$isOldStyleMaven" == "true" ]]
then
  echo "LEGACY deployment -  Manual upload from ossrh-staging to Maven Central"

  bearer_token=$(echo -n "$MAVENCENTRAL_USERNAME:$MAVENCENTRAL_TOKEN" | base64)

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
fi

popd

cp -f gerrit/bazel-bin/Documentation/searchfree.zip .
cp -f gerrit/bazel-bin/release.war gerrit-"$version".war

echo "gerrit.war checksums"
shasum gerrit-"$version".war
shasum -a 256 gerrit-"$version".war
md5sum gerrit-"$version".war

echo "Pushing gerrit.war to gerrit-releases ..."
gcloud storage cp gerrit-"$version".war gs://gerrit-releases/gerrit-"$version".war

echo "Pushing gerrit documentation to gerrit-documentation ..."
unzip searchfree.zip
pushd Documentation
version_no_rc=$(echo "$version" | cut -d '-' -f 1)
gcloud storage cp --recursive . gs://gerrit-documentation/Documentation/"$version_no_rc"
popd

echo "Setting next version tag to $nextversion ..."
pushd gerrit
git clean -fdx
./tools/version.py "$nextversion"
git commit -a -m 'Set version to '$nextversion'

Release-Notes: skip'
test $DRY_RUN = true || test $DRY_RUN = TRUE || git push origin HEAD:refs/for/"$branch"
popd

echo "Release completed"
