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
  static String gerritReviewer = "GerritForge CI <gerritforge@gmail.com>"
  static long curlTimeout = 10000
  static SimpleDateFormat tsFormat = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss.S Z")
  static int maxChanges = 100
  static int numRetryBuilds = 3
  static int myAccountId = 1022687
  static int waitForResultTimeout = 10000
}

def gerritPost(url, jsonPayload) {
  def gerritPostUrl = Globals.gerrit + url
  def curl = ['curl', '-n',
    "-X", "POST", "-H", "Content-Type: application/json",
    "--data-binary", jsonPayload,
    gerritPostUrl ]
  println "Executing '" + curl.join(" ") + "'"
  def proc = curl.execute()
  def sout = new StringBuffer(), serr = new StringBuffer()
  proc.consumeProcessOutput(sout, serr)
  proc.waitForOrKill(Globals.curlTimeout)
  def curlExit = proc.exitValue()
  println "--- OUTPUT ---"
  println sout
  println "--- ERROR ---"
  println serr
  println "--- EXIT: " + curlExit + " ---"
  return curlExit
}

def gerritReview(buildUrl,changeNum, sha1, verified, msgPrefix) {
  def addReviewerExit = gerritPost("a/changes/" + changeNum + "/reviewers", '{ "reviewer" : "' +
                                   Globals.gerritReviewer + '" }')
  if(addReviewerExit != 0) {
    println "**** ERROR: cannot add myself as reviewer of change " + changeNum + " *****"
    return addReviewerExit
  }

  def jsonPayload = '{"labels":{"Code-Review":0,"Verified":' + verified + '},' +
                    ' "message": "' + msgPrefix + 'Gerrit-CI Build: ' + buildUrl + '", ' +
                    ' "notify" : "' + (verified < 0 ? "OWNER":"NONE") + '" }'
  def addVerifiedExit = gerritPost("a/changes/" + changeNum + "/revisions/" + sha1 + "/review",
                                   jsonPayload)

  if(addVerifiedExit == 0) {
    println "----------------------------------------------------------------------------"
    println "Gerrit Review: Verified=" + verified + " to change " + changeNum + "/" + sha1
    println "----------------------------------------------------------------------------"
  }
  return addVerifiedExit
}

def waitForResult(build) {
  def result = null
  def startWait = System.currentTimeMillis()
  while(result == null && (System.currentTimeMillis() - startWait) < Globals.waitForResultTimeout) {
    result = build.getResult()
    if(result == null) {
      Thread.sleep(100) {
      }
    }
  }
  return result == null ? Result.FAILURE : result
}

def buildChange(change) {
  def sha1 = change.current_revision
  def changeNum = change._number
  def revision = change.revisions.get(sha1)
  def ref = revision.ref
  def patchNum = revision._number
  def branch = change.branch
  def changeUrl = Globals.gerrit + "#/c/" + changeNum + "/" + patchNum
  def refspec = "+" + ref + ":" + ref.replaceAll('ref/', 'ref/remotes/origin/')

  println "Building Change " + changeUrl

  def b
  ignore(FAILURE) {
    retry ( Globals.numRetryBuilds ) {
      b = build("Gerrit-verifier-default", REFSPEC: refspec, BRANCH: sha1,
                CHANGE_URL: changeUrl)
    }
  }
  def result = waitForResult(b)
  gerritReview(b.getBuildUrl() + "consoleText",changeNum,sha1,result == Result.SUCCESS ? +1:-1, "")

  if(result == Result.SUCCESS && branch=="master") {
    ignore(FAILURE) {
      retry ( Globals.numRetryBuilds ) {
        b = build("Gerrit-verifier-notedb", REFSPEC: refspec, BRANCH: sha1,
                  CHANGE_URL: changeUrl)
      }
    }

    result = waitForResult(b)
    gerritReview(b.getBuildUrl() + "consoleText",changeNum,sha1,
      result == Result.SUCCESS ? +1:-1, "NoteDB - ")
  }
}


def lastBuild = build.getPreviousSuccessfulBuild()
def logOut = new ByteArrayOutputStream()
if(lastBuild != null) {
  lastBuild.getLogText().writeLogTo(0,logOut)
}

def lastLog = new String(logOut.toByteArray())
def lastBuildStartTimeMillis = lastBuild == null ?
  (System.currentTimeMillis() - 1800000) : lastBuild.getStartTimeInMillis()
def sinceMillis = lastBuildStartTimeMillis - 30000
def since = Globals.tsFormat.format(new Date(sinceMillis))

if(lastBuild != null) {
  println "Last successful build was " + lastBuild.toString()
}

def gerritQuery = "status:open project:gerrit since:\"" + since + "\""

def requestedChangeId = params.get("CHANGE_ID")

def processAll = requestedChangeId.equals("ALL")

queryUrl = processAll ?
  new URL(Globals.gerrit + "changes/?pp=0&O=3&n=" + Globals.maxChanges + "&q=" +
                      gerritQuery.encodeURL()) :
  new URL(Globals.gerrit + "changes/?pp=0&O=3&q=" + requestedChangeId)

def changes = queryUrl.getText().substring(5)
def jsonSlurper = new JsonSlurper()
def changesJson = jsonSlurper.parseText(changes)
int numChanges = changesJson.size()

println "Gerrit has " + numChanges + " change(s) since " + since
println "================================================================================"


for (change in changesJson) {
  def sha1 = change.current_revision
  if(processAll && lastLog.contains(sha1)) {
      println "Skipping SHA1 " + sha1 + " because has been already built by " + lastBuild
      continue
  }

  def verified = change.labels.Verified
  def approved = verified.approved
  def rejected = verified.rejected 

  if(processAll && approved != null && approved._account_id == Globals.myAccountId) {
    println "I have already approved " + sha1 + " commit: SKIPPING"
  } else if(processAll && rejected != null && rejected._account_id == Globals.myAccountId) {
    println "I have already rejected " + sha1 + " commit: SKIPPING"
  } else {
    buildChange(change)
  }
}



