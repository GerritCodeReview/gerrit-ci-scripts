// Copyright (C) 2019 The Android Open Source Project
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

import com.cloudbees.groovy.cps.NonCPS
import groovy.json.JsonSlurper
import java.text.SimpleDateFormat
import java.util.concurrent.TimeUnit

class Globals {
    static final def gerrit = "https://gerrit-review.googlesource.com/"
    static final def maxChanges = 500
    static final def pollMinutes = 5
    static final def tsFormat = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss.S Z")
    static final def hookUrl = "${env.JENKINS_URL}gerrit-webhook/"
}

import static Globals.*

@NonCPS
def listChangedProjects() {
    def lastBuild = currentBuild.rawBuild.getPreviousSuccessfulBuild()
    def lastBuildStartTimeMillis = lastBuild == null ?
            (System.currentTimeMillis() - TimeUnit.MINUTES.toMillis(pollMinutes * 2)) : lastBuild.getStartTimeInMillis()
    def sinceMillis = lastBuildStartTimeMillis - TimeUnit.MINUTES.toMillis(pollMinutes)
    def since = tsFormat.format(new Date(sinceMillis))

    if (lastBuild != null) {
        println "Last successful build was " + lastBuild.toString()
    }
    println "Querying Gerrit for last modified changes since ${since} ..."

    def gerritQuery = "status:open since:\"${since}\""
    def queryUrl = new URL("${gerrit}changes/?pp=0&n=${maxChanges}&q=${gerritQuery.encodeURL()}")
    def changes = queryUrl.getText().substring(5)
    def jsonSlurper = new JsonSlurper()
    def changesJson = jsonSlurper.parseText(changes)
    return changesJson.collect { it.project } as Set
}

node('master') {
    listChangedProjects().each { project ->
        stage("${project}") {
            def jsonPayload = '{"project":{"name":"' + project +
                    '"}, "type":"patchset-created"}'
            sh "curl -d '${jsonPayload}' $hookUrl"
        }
    }
}
