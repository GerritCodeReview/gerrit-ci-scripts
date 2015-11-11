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
  static String gerritReviewer = "luca.milanesio@gmail.com"
  static long curlTimeout = 10000
  static SimpleDateFormat tsFormat = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss.S Z")
}

def gerritPost(url, jsonPayload) {
  def gerritPostUrl = Globals.gerrit + url
  def curl = ['curl', '-n',
    "-X", "POST", "-H", "'Content-Type: application/json'", 
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

def gerritReview(buildUrl,changeNum, sha1, verified) {
  def addReviewerExit = gerritPost("a/changes/" + changeNum + "/reviewers", '{ "reviewer" : "' + Globals.gerritReviewer + '" }')
  if(addReviewerExit != 0) {
    println "**** ERROR: cannot add myself as reviewer of change " + changeNum + " *****"
    return addReviewerExit
  }

  def jsonPayload = '{"labels":{"Code-Review":0,"Verified":' + verified + '}, "message": "Gerrit-CI Build: ' + buildUrl + '"}'
  def addVerifiedExit = gerritPost("a/changes/" + changeNum + "/revisions/" + sha1 + "/review", jsonPayload)
  
  if(addVerifiedExit == 0) {
    println "----------------------------------------------------------------------------"
    println "Gerrit Review: Verified" + verified + " to change " + changeNum + "/" + sha1
    println "----------------------------------------------------------------------------"
  }
  return addVerifiedExit
}

def lastBuild = build.getPreviousSuccessfulBuild()
def logOut = new ByteArrayOutputStream()
if(lastBuild != null) {
  lastBuild.getLogText().writeLogTo(0,logOut)
}

def lastLog = new String(logOut.toByteArray())
def lastBuildStartTimeMillis = lastBuild == null ? (System.currentTimeMillis() - 1800000) : lastBuild.getStartTimeInMillis()
def sinceMillis = lastBuildStartTimeMillis - 30000
def since = Globals.tsFormat.format(new Date(sinceMillis))

if(lastBuild != null) {
  println "Last successful build was " + lastBuild.toString()
}

def gerritQuery = "status:open project:gerrit since:\"" + since + "\""

def changes = new URL(Globals.gerrit + "changes/?pp=0&O=3&n=1&q=" + gerritQuery.encodeURL()).getText().substring(5)
def jsonSlurper = new JsonSlurper()
def changesJson = jsonSlurper.parseText(changes)
int numChanges = changesJson.size()

println "Gerrit has " + numChanges + " change(s) since " + since
println "================================================================================"


for (change in changesJson) {
  def sha1 = change.current_revision
  if(lastLog.contains(sha1)) {
      println "Skipping SHA1 " + sha1 + " because has been already built by " + lastBuild
      continue
  } 

  def changeNum = change._number
  def ref = change.revisions.get(sha1).fetch.http.ref
  def refspec = "+" + ref + ":" + ref.replaceAll('ref/', 'ref/remotes/origin/')
  println "Building Change " + ref

  def b
  ignore(FAILURE) {
    b = build( "Gerrit-verifier", REFSPEC: refspec, BRANCH: sha1 )
  }
  def result = b.getResult()

  gerritReview(b.getBuildUrl(),changeNum,sha1,result == Result.SUCCESS ? +1:-1)          
}
