import hudson.model.*
import hudson.AbortException
import hudson.console.HyperlinkNote
import java.util.concurrent.CancellationException
import groovy.json.*

String.metaClass.encodeURL = {
  java.net.URLEncoder.encode(delegate)
}

def gerrit = "https://gerrit-review.googlesource.com/"
def gerritQuery = "status:open project:gerrit"

def changes = new URL(gerrit + "/changes/?pp=0&O=3&n=1&q=" + gerritQuery.encodeURL()).getText().substring(5)
def jsonSlurper = new JsonSlurper()
def changesJson = jsonSlurper.parseText(changes)

for (change in changesJson) {
  def sha1 = change.current_revision
  def ref = change.revisions.get(sha1).fetch.http.ref
  def refspec = "+" + ref + ":" + ref.replaceAll('ref/', 'ref/remotes/origin/')
  println "Building Change " + ref + " on SHA1 " + sha1

  def b
  ignore(FAILURE) {
    b = build( "Gerrit-verifier", REFSPEC: refspec, BRANCH: sha1 )
  }

  def result = b.getResult()
    if(result == Result.SUCCESS) {
    println "Build SUCCEDED, WOW !"
  } else {
    println "Build FAILED, I am sorry ;-("
  }
}
