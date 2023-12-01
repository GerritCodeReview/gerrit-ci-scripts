#!/bin/bash -e

if [ "$1" == "--help" ] || [ "$1" == "" ] || [ "$2" == "" ]
then
  echo "Gerrit Code Review - release upgrade verification script"
  echo "--------------------------------------------------------"
  echo "Verify that Gerrit <previous-version> can be migrated to <next-version>"
  echo "without online reindexing."
  echo ""
  echo "The gerrit-<previous-version>.war and gerrit-<next-version>.war are either found in the"
  echo "current directory or downloaded from https://gerrit-releases.storage.googleapis.com"
  echo ""
  echo "Use: $0 <previous-version> <next-version>"
  echo ""
  echo "Where: previous-version Gerrit version to migrate from"
  echo "       next-version Gerrit version to migrate to"
  echo ""
  echo "Example: $0 3.8.3 3.9.1"
  exit 1
fi

export gerritReleasesUrl=https://gerrit-releases.storage.googleapis.com
export previousVersionWar=gerrit-$1.war
export nextVersionWar=gerrit-$2.war

function downloadGerritWar
{
  if checkWar $1
  then
    echo "$1 found locally"
  else
    echo "Downloading $1 from $gerritReleasesUrl"
    curl -O $gerritReleasesUrl/$1
  fi
}

function checkWar
{
  if [ -f $1 ]
  then
    java -jar $1 --version || return 1
  else
    return 2
  fi

  return 0
}

function log
{
  echo ""
  echo $1
  echo "================================="
}

log "Installing $previousVersionWar ... "

downloadGerritWar $previousVersionWar
gerritSite=$(basename $previousVersionWar .war)

if [ -d $gerritSite ]
then
  $gerritSite/bin/gerrit.sh stop
  rm -Rf $gerritSite
fi

java -jar $previousVersionWar init --install-all-plugins -d $gerritSite --batch --dev
echo "Gerrit $previousVersionWar installed and running as pid=$(cat $gerritSite/bin/gerrit.pid)"

testProject="test-project-upgrade"
log "Creating project $testProject ... "

curl -s --fail -u admin:secret -X PUT http://localhost:8080/a/projects/$testProject

rm -Rf $testProject
log "Cloning $testProject ... "

git clone http://admin@localhost:8080/a/$testProject && (cd $testProject && f=`git rev-parse --git-dir`/hooks/commit-msg ; mkdir -p $(dirname $f) ; curl -Lo $f http://localhost:8080/tools/hooks/commit-msg ; chmod +x $f)
pushd $testProject
git config user.name "John Doe"
git config user.email "john@gerrit.mycompany.local"

log "Creating a local change ..."

echo "Test change" > README.md
git add README.md
git commit -m "Test change"
git push origin HEAD:refs/for/master

log "Shutting down $gerritSite"
popd
$gerritSite/bin/gerrit.sh stop

log "Upgrading to $nextVersionWar ... "

downloadGerritWar $nextVersionWar
java -jar $nextVersionWar init --install-all-plugins  -d $gerritSite --batch
$gerritSite/bin/gerrit.sh start

log "Checking if the change created with $previousVersionWar still exists"

CHANGES=$(curl -s --fail curl 'http://localhost:8080/changes/?q=status%3Aopen' | tail -1)

if [ "$CHANGES" == "[]" ]
then
  echo "*** FAILED ***"
  echo "No changes found after upgrading from $previousVersionWar to $nextVersionWar"
  echo "$CHANGES"
  exit 1
else
  $gerritSite/bin/gerrit.sh stop
  log "Migration from $previousVersionWar to $nextVersionWar SUCCEEDED"
fi
