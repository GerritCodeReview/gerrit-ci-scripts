import groovy.json.*
import hudson.model.*
import java.text.*

class Globals {
  static String gerrit = "https://gerrit-review.googlesource.com/"
  static String jenkins = "https://gerrit-ci.gerritforge.com/"
  static SimpleDateFormat tsFormat = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss.S Z")
  static int maxChanges = 100
  static int myAccountId = 1022687
  static int maxBuilds = 16
  static String verifierJobName = "Gerrit-verifier-change"
  static String[] changesTodo = []
  static Map builds = [:]
}

def getLastBuildTime(){
  def previousBuildTime = currentBuild.rawBuild.getPreviousSuccessfulBuild().getStartTimeInMillis()
  def lastBuildStartTimeMillis = previousBuildTime == null ?
    (System.currentTimeMillis() - 1800000) : previousBuildTime
  def sinceMillis = lastBuildStartTimeMillis - (24 * 3600 * 1000)
  return Globals.tsFormat.format(new Date(sinceMillis))
}

def getBuildsSinceLastQueryUrl(){
  def since = getLastBuildTime()
  def gerritQuery = "status:open project:gerrit since:\"" + since + "\""

  println ""
  println "Querying Gerrit for last modified changes since ${since} ..."

  return new URL(Globals.gerrit +
    "changes/?pp=0&o=CURRENT_REVISION&o=DETAILED_ACCOUNTS&o=DETAILED_LABELS&n=" +
    Globals.maxChanges +
    "&q=" +
    java.net.URLEncoder.encode(gerritQuery, "UTF-8"))
}

def fetchChanges(){
  def queryUrl = getBuildsSinceLastQueryUrl()
  def changes = queryUrl.getText().substring(5)
  def jsonSlurper = new JsonSlurper()
  return jsonSlurper.parseText(changes)
}

def changeUrl(change) {
  "${Globals.gerrit}${change}"
}

def changeOfBuildRun(run) {
  def params = run.allActions.findAll { it in hudson.model.ParametersAction }
  return params.collect { it.getParameter("CHANGE_ID").value }
}

def getBuildRunsInProgressNums() {
  def verifierChangeJob = Jenkins.instance.getJob(Globals.verifierJobName)
  def verifierRuns = verifierChangeJob.builds
  def pendingBuilds = verifierRuns.findAll { it.building }

  if(!pendingBuilds.empty) {
    println ""
    println "Changes currently in progress: "
    pendingBuilds.each {
      b -> println("Change ${changeUrl(changeOfBuildRun(b)[0])}: ${Globals.jenkins}${b.url}")
    }
  }

  return pendingBuilds.collect { changeOfBuildRun(it) }.flatten()
}

def getAcceptedChanges(changes){
  return changes.findAll {
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
}

def filterCanges(buildRunsInProgressNums){
  def changes = fetchChanges()
  def acceptedChanges = getAcceptedChanges(changes)
  def todoChangesNums = acceptedChanges.collect { "${it._number}" }
  return todoChangesNums - buildRunsInProgressNums
}

def printSummary(filteredChanges, buildsBandwith){
  println ""
  println "Gerrit has " + filteredChanges.size() + " change(s) since " + getLastBuildTime() +
    " $filteredChanges"
  if(buildsBandwith <= 0) {
    println "... but there is NO bandwidth for further builds yet"
  }
  else {
    if(filteredChanges.size() > buildsBandwith) {
      println "... but I've got bandwidth for only ${buildsBandwith} of them at the moment"
    }
  }
  println "================================================================================"
}


def prepareBuilds(){
  def buildRunsInProgressNums = getBuildRunsInProgressNums()
  def filteredChanges = filterCanges(buildRunsInProgressNums)
  def buildsBandwith = Globals.maxBuilds - buildRunsInProgressNums.size

  printSummary(filteredChanges, buildsBandwith)

  if(buildsBandwith > 0 && filteredChanges.size() > 0) {
    Globals.changesTodo = filteredChanges.reverse().take(buildsBandwith)

    Globals.changesTodo.each {
      println "Building change: ${changeUrl(it)} ..."
    }

  } else {
    println "Nothing to build."
  }

}

def formatBuild(change){
  return {
    build job: "${Globals.verifierJobName}",
          parameters: [string(name: 'CHANGE_ID', value: change)],
          propagate: false
  }
}


node('master'){
  stage('Select Changes'){
    prepareBuilds()
  }
  stage('Build'){
    if (Globals.changesTodo.size() > 0){
      parallel Globals.changesTodo.collectEntries { ["${it}": formatBuild(it)] }
    }
  }
}
