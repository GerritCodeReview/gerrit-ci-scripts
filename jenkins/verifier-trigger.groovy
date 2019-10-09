import groovy.json.JsonSlurper
import java.text.SimpleDateFormat
import com.cloudbees.groovy.cps.NonCPS

@NonCPS
def listChangedProjects() {
    def gerrit = "https://gerrit-review.googlesource.com/"
    def maxChanges = 100
    def lastBuild = currentBuild.rawBuild.getPreviousSuccessfulBuild()
    def lastBuildStartTimeMillis = lastBuild == null ?
            (System.currentTimeMillis() - 1800000) : lastBuild.getStartTimeInMillis()
    def sinceMillis = lastBuildStartTimeMillis - (24 * 3600 * 1000)
    def tsFormat = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss.S Z")
    def since = tsFormat.format(new Date(sinceMillis))

    if (lastBuild != null) {
        println "Last successful build was " + lastBuild.toString()
    }
    println "Querying Gerrit for last modified changes since ${since} ..."

    def gerritQuery = "status:open since:\"" + since + "\""
    def queryUrl = new URL(gerrit + "changes/?pp=0&o=CURRENT_REVISION&o=DETAILED_ACCOUNTS&o=DETAILED_LABELS&n=" + maxChanges + "&q=" +
            gerritQuery.encodeURL())

    def changes = queryUrl.getText().substring(5)
    def jsonSlurper = new JsonSlurper()
    def changesJson = jsonSlurper.parseText(changes)
    return changesJson.collect { it.project } as Set
}

node ('master') {
    def projects = listChangedProjects()

    println "Reindexing projects: $projects"
    hookUrl = "${env.JENKINS_URL}gerrit-webhook/"

    projects.each { project ->
        stage("${project}") {
            def jsonPayload = '{"project":{"name":"' + project +
                    '"}, "type":"patchset-created"}'
            def cmd = ["curl", "-v", "-d", jsonPayload, hookUrl]
            println cmd
            def exec = cmd.execute()
            exec.waitFor()
            if (exec.exitValue() > 0) {
                error "Could not trigger job for ${project}"
            }
        }
    }
}
