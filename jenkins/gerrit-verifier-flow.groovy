// Copyright (C) 2015 The Android Open Source Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import hudson.model.*
import hudson.AbortException
import hudson.console.HyperlinkNote
import java.util.concurrent.CancellationException
import groovy.json.*
import java.text.*

String.metaClass.encodeURL = {
  java.net.URLEncoder.encode(delegate)
}

class Globals {
  static String gerrit = "https://gerrit-review.googlesource.com/"
  static String jenkins = "https://gerrit-ci.gerritforge.com/"
  static String gerritReviewer = "GerritForge CI <gerritforge@gmail.com>"
  static long curlTimeout = 10000
  static SimpleDateFormat tsFormat = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss.S Z")
  static int maxChanges = 100
  static int numRetryBuilds = 3
  static int myAccountId = 1022687
  static int waitForResultTimeout = 10000
  static int maxBuilds = 4
  static String verifierJobName = "Gerrit-verifier-change"
}

def lastBuild = build.getPreviousSuccessfulBuild()

def lastBuildStartTimeMillis = lastBuild == null ?
  (System.currentTimeMillis() - 1800000) : lastBuild.getStartTimeInMillis()
def sinceMillis = lastBuildStartTimeMillis - (24 * 3600 * 1000)
def since = Globals.tsFormat.format(new Date(sinceMillis))

if(lastBuild != null) {
  println "Last successful build was " + lastBuild.toString()
}

println ""
println "Querying Gerrit for last modified changes since ${since} ..."

def gerritQuery = "status:open project:gerrit since:\"" + since + "\""

queryUrl = new URL(Globals.gerrit + "changes/?pp=0&o=CURRENT_REVISION&o=DETAILED_ACCOUNTS&o=DETAILED_LABELS&n=" + Globals.maxChanges + "&q=" +
                      gerritQuery.encodeURL())

def changes = queryUrl.getText().substring(5)
def jsonSlurper = new JsonSlurper()
def changesJson = jsonSlurper.parseText(changes)

def getBuildRunsInProgress() {
  def verifierChangeJob = Hudson.instance.getJob(Globals.verifierJobName)
  def verifierRuns = verifierChangeJob.builds
  def pendingBuilds = verifierRuns.findAll { it.building }
  return pendingBuilds
}

def changeOfBuildRun(run) {
  def params = run.allActions.findAll { it in hudson.model.ParametersAction }
  return params.collect { it.getParameter("CHANGE_ID").value }
}

def changeUrl(change) {
  "${Globals.gerrit}${change}"
}

def acceptedChanges = changesJson.findAll {
  change ->
  sha1 = change.current_revision
  if(sha1 == null) {
      println "[WARNING] Skipping change ${changeUrl(change._number)} because it does not have any current revision or patch-set"
      return false
  }

  if(!change.mergeable) {
      println "[WARNING] Skipping change ${changeUrl(change._number)} because has merge conflicts"
      return false
  }

  if(change.hashtags.contains("skipci")) {
      println "[WARNING] Skipping change ${changeUrl(change._number)} because it is tagged with #skipci"
      return false
  }

  def canBeVerified = change.labels.Verified
  if(canBeVerified != null) {
    def verified = canBeVerified.all
    if(verified == null) {
      true
    } else {
      def myVerifications = verified.findAll {
        verification -> verification._account_id == Globals.myAccountId && verification.value != 0
      }
      return myVerifications.empty
    }
  }
}

def inProgress = getBuildRunsInProgress()
if(!inProgress.empty) {
  println ""
  println "Changes currently in progress: "
  inProgress.each {
    b -> println("Change ${changeUrl(changeOfBuildRun(b)[0])}: ${Globals.jenkins}${b.url}")
  }
}

def inProgressChangesNums = inProgress.collect { changeOfBuildRun(it) }.flatten()
def todoChangesNums = acceptedChanges.collect { "${it._number}" }
def filteredChanges = todoChangesNums - inProgressChangesNums

def buildsBandwith = Globals.maxBuilds - inProgressChangesNums.size

println ""
println "Gerrit has " + filteredChanges.size() + " change(s) since " + since + " $filteredChanges"
if(buildsBandwith <= 0) {
  println "... but there is NO bandwidth for further builds yet"
}
else {
  if(filteredChanges.size() > buildsBandwith) {
    println "... but I've got bandwidth for only ${buildsBandwith} of them at the moment"
  }
}
println "================================================================================"

if(buildsBandwith > 0) {
  def changesTodo = filteredChanges.reverse().take(buildsBandwith)

  changesTodo.each {
    println "Building change: ${changeUrl(it)} ..."
  }

  def builds = changesTodo.collect { change -> { -> build(Globals.verifierJobName, CHANGE_ID: change) } }
  parallel(builds)
}
