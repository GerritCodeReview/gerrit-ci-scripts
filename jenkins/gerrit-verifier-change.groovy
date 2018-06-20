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


class Config {
    static String gitUser = "Jenkins Build"
    static String gitEmail = "jenkins@gerritforge.com"
    static long curlTimeout = 10000
    static int retryTimes = 3
    static String addVerifiedTag = " \"tag\" : \"autogenerated:gerrit-ci:addVerified\" "
    static Set<String> codeStyleBranches = ["master", "stable-2.14", "stable-2.15"]
    static resTicks = [ 'ABORTED':'\u26aa', 'SUCCESS':'\u2705', 'FAILURE':'\u274c' ]
    static boolean verbose = true
}

class Change {
    static Map changeJson = [:]
    static String sha1 = ""
    static String changeNum = ""
    static String branch = ""
    static Map revision = [:]
    static String ref = ""
    static String patchNum = ""
    static String changeUrl = ""
}

class Builds {
    static String tool = ""
    static Set<String> modes = ["reviewdb"]
    static Result resultCodeStyle = null
    static Run buildCodeStyle = null
    static Map resultsVerification = [:]
    static Map buildsVerification = [:]
}

class Gerrit {
    Script script
    String url = "https://gerrit-review.googlesource.com/"
    String repository = "gerrit"
    boolean verbose = true

    int applyVerificationLabel(verificationScore) {
        if(verificationScore == 0) {
            return;
        }

        def msgList = Builds.buildsVerification.collect { type,build -> [
                'type': type,
                'res': build.result.toString(),
                'url': build.getAbsoluteUrl() + "consoleText"
            ]
        }

        def msgBody = msgList.collect {
            "${Config.resTicks[it.res]} ${it.type} : ${it.res}\n    (${it.url})"
        } .join('\n')

        def addVerifiedExit = generateAndPostLabelPayload('Verified', verificationScore, msgBody)
        if(addVerifiedExit == 0) {
            this.script.println "----------------------------------------------------------------------------"
            this.script.println "Gerrit Review: Verified=${verificationScore} to change " +
                "${Change.changeJson._number}/${Change.sha1}"
            this.script.println "----------------------------------------------------------------------------"
        }

        return addVerifiedExit
    }

    int applyCodestyleLabel(codeStyleScore, files) {
        if(codeStyleScore == 0) {
            return
        }

        def formattingMsg = codeStyleScore < 0 ?
            ('The following files need formatting:\n    ' + files.join('\n    ')) :
            'All files are correctly formatted'
        def res = Builds.resultCodeStyle.toString()
        def url = Builds.buildCodeStyle.getAbsoluteUrl() + "consoleText"

        def msgBody = "${Config.resTicks[res]} ${formattingMsg}\n    (${url})"

        def addCodeStyleExit = generateAndPostLabelPayload('Code-Style', codeStyleScore, msgBody)
        if(addCodeStyleExit == 0) {
            this.script.println "----------------------------------------------------------------------------"
            this.script.println "Gerrit Review: Code-Style=${codeStyleScore} to change" +
                "${Change.changeJson._number} / ${Change.sha1}"
            this.script.println "----------------------------------------------------------------------------"
        }

        return addCodeStyleExit
    }

    private int postToGerrit(url, jsonPayload) {
        def error = ""
        def gerritPostUrl = this.url + url
        def curl = ['curl',
            '-n', '-s', '-S',
            '-X', 'POST', '-H', 'Content-Type: application/json',
            '--data-binary', jsonPayload,
            gerritPostUrl ]
        if(Config.verbose) { this.script.println "CURL/EXEC> ${curl}" }
        def proc = curl.execute()
        def sout = new StringBuffer(), serr = new StringBuffer()
        proc.consumeProcessOutput(sout, serr)
        proc.waitForOrKill(Config.curlTimeout)
        def curlExit = proc.exitValue()
        if(curlExit != 0) {
            error = "${curl} **FAILED** with exit code = ${curlExit}"
            this.script.println error
            throw new IOException(error)
        }

        if(!sout.toString().trim().isEmpty() && Config.verbose) {
            this.script.println "CURL/OUTPUT> ${sout}"
        }
        if(!serr.toString().trim().isEmpty() && Config.verbose) {
            this.script.println "CURL/ERROR> ${serr}"
        }

        return 0
    }

    private int generateAndPostLabelPayload(label, score, msgBody = "") {
        def notify = score < 0 ? ', "notify" : "OWNER"' : ''
        def jsonPayload = '{"labels":{"' + label + '":' + score + '},' +
                            ' "message": "' + msgBody + '"' +
                            notify + ", ${Config.addVerifiedTag} }"

        return postToGerrit("a/changes/${Change.changeJson._number}/revisions/${Change.sha1}/review",
            jsonPayload)
    }
}

def findCodestyleFilesInLog() {
    def codestyleFiles = []
    def needsFormatting = false
    def codestyleLogReader = Builds.buildCodeStyle.getLogReader()
    codestyleLogReader.eachLine {
        needsFormatting = needsFormatting || (it ==~ /.*Need Formatting.*/)
        if(needsFormatting && it ==~ /\[.*\]/) {
        codestyleFiles += it.substring(1,it.length()-1)
        }
    }

    return codestyleFiles
}

def getVotingScore(acc, res) {
    if(res == null || res == Result.ABORTED) {
        return 0
    }

    switch(acc) {
            case 0: return 0
            case 1:
            if(res == null) {
                return 0;
            }
            switch(res) {
                case Result.SUCCESS: return +1;
                case Result.FAILURE: return -1;
                default: return 0;
            }
            case -1: return -1
    }
}

def getChangedFiles() {
    URL filesUrl = new URL(String.format("%schanges/%s/revisions/%s/files/",
        gerrit.url, Change.changeNum, Change.sha1))
    def files = filesUrl.getText().substring(5)
    def filesJson = new JsonSlurper().parseText(files)
    filesJson.keySet().findAll { it != "/COMMIT_MSG" }
}

def formatBuildStep(buildName, mode, retries = 1) {
    def propagate = retries == 1 ? false : true
    return {
        catchError{
            retry(retries){
                def slaveBuild = build job: "${buildName}", parameters: [
                    string(name: 'REFSPEC', value: Change.ref),
                    string(name: 'BRANCH', value: Change.sha1),
                    string(name: 'CHANGE_URL', value: Change.changeUrl),
                    string(name: 'MODE', value: mode),
                    string(name: 'TARGET_BRANCH', value: Change.branch)
                ], propagate: propagate
                if (buildName == "Gerrit-codestyle"){
                    Builds.buildCodeStyle = slaveBuild.rawBuild
                    Builds.resultCodeStyle = slaveBuild.rawBuild.result
                } else {
                    Builds.buildsVerification["${mode}"] = slaveBuild.rawBuild
                    Builds.resultsVerification["${mode}"] = slaveBuild.rawBuild.result
                }
            }
        }
    }
}

def getWorkspace(){
    println "workspace: ${WORKSPACE}"
    def cwd = new File("${WORKSPACE}")
    println "cwd: ${cwd}"
    return cwd
}

def executeShellCommand(cwd, command) {
    def sout = new StringBuilder(), serr = new StringBuilder()
    println "SH: ${command}"
    def shell = command.execute([],cwd)
    shell.consumeProcessOutput(sout, serr)
    shell.waitFor()
    println "OUT: ${sout}"
    println "ERR: ${serr}"
}

def initializeGit(cwd){
    executeShellCommand(cwd, "git fetch origin ${Change.ref}")
    executeShellCommand(cwd, "git checkout FETCH_HEAD")
    executeShellCommand(cwd, "git fetch origin ${Change.branch}")
    executeShellCommand(cwd, "git config user.name \"${Config.gitUser}\"")
    executeShellCommand(cwd, "git config user.email \"${Config.gitEmail}\"")
    executeShellCommand(cwd, 'git merge --no-commit --no-edit --no-ff FETCH_HEAD')
}

def collectBuildTool(cwd){
    if(new java.io.File("${cwd}/BUCK").exists()) {
        Builds.tool = "buck"
    } else if(new java.io.File("${cwd}/BUILD").exists()) {
        Builds.tool = "bazel"
    }
}

def collectBuildModes(){
    if(Change.branch == "master" || Change.branch == "stable-2.15") {
        Builds.modes += "notedb"
    }

    if(Change.branch == "master" || Change.branch == "stable-2.15" ||
        Change.branch == "stable-2.14") {
        def changedFiles = getChangedFiles()
        def polygerritFiles = changedFiles.findAll { it.startsWith("polygerrit-ui") }

        if(polygerritFiles.size() > 0) {
            if(changedFiles.size() == polygerritFiles.size()) {
                println "Only PolyGerrit UI changes detected, skipping other test modes..."
                Builds.modes = ["polygerrit"]
            } else {
                println "PolyGerrit UI changes detected, adding 'polygerrit' validation..."
                Builds.modes += "polygerrit"
            }
        }
    }
}

def findFlakyBuilds() {
    def flaky = Builds.buildsVerification.findAll { it.value.result == null ||
        it.value.result != Result.SUCCESS }
    if(flaky.size() == Builds.resultsVerification.size()) {
        return []
    }

    def retryBuilds = []

    flaky.each {
        def mode = it.key
        Builds.resultsVerification.remove(mode)
        Builds.buildsVerification.remove(mode)
        retryBuilds += mode
    }
    return retryBuilds
}

def fetchChange(){
    def requestedChangeId = params.get("CHANGE_ID")
    def queryUrl =
        new URL("${gerrit.url}changes/${requestedChangeId}/?pp=0&O=3")
    def response = queryUrl.getText().substring(5)
    def jsonSlurper = new JsonSlurper()
    Change.changeJson = jsonSlurper.parseText(response)
}

def extractChangeMetaData(){
    Change.sha1 = Change.changeJson.current_revision
    Change.changeNum = Change.changeJson._number
    Change.branch = Change.changeJson.branch
    Change.revision = Change.changeJson.revisions.get(Change.sha1)
    Change.ref = Change.revision.ref
    Change.patchNum = Change.revision._number
    Change.changeUrl = gerrit.url + "#/c/" + Change.changeNum +
        "/" + Change.patchNum
}

gerrit = new Gerrit(script:this)

node('master') {
    git url: "${gerrit.url}${gerrit.repository}"
    stage('Preparing'){
        fetchChange()
        extractChangeMetaData()
        def build = currentBuild.rawBuild

        build.setDescription(
            """<a href='${Change.changeUrl}' target='_blank'>""" +
                """Change #${Change.changeNum}""" +
            """</a>""")

        if(Change.sha1 == null) {
            error("[WARNING] Skipping change ${Change.changeJson.change_id}" +
                " because it does not have any current revision or patch-set")
        }
        def cwd = getWorkspace()
        initializeGit(cwd)
        collectBuildTool(cwd)
        collectBuildModes()
    }
    stage('Check Codestyle'){
        println "Checking codestyle of ${Change.changeUrl}"

        parallel "Gerrit-codestyle": formatBuildStep("Gerrit-codestyle", "reviewdb")
    }
    stage('Verification'){
        println "Verifying Change ${Change.changeUrl}"

        parallel Builds.modes.collectEntries {
            ["Gerrit-verification(${it})" : formatBuildStep("Gerrit-verifier-${Builds.tool}", it)]
        }
    }
    stage('Retry Flaky Builds'){
        def flakyBuildsModes = findFlakyBuilds()
        if (flakyBuildsModes.size() > 0){
            println "Retrying flaky builds."
            parallel flakyBuildsModes.collectEntries {
                ["Gerrit-verification(${it})" :
                    formatBuildStep("Gerrit-verifier-${Builds.tool}", it, Config.retryTimes)]
            }
        }
    }
    stage('Vote'){
        if(Builds.resultCodeStyle) {
            def codeStyleScore = getVotingScore(1, Builds.resultCodeStyle)
            gerrit.applyCodestyleLabel(codeStyleScore, findCodestyleFilesInLog())
        }

        def verificationResults = Builds.resultsVerification.collect {
            k, v -> v
        }
        def verificationScore = verificationResults.inject(1) {
            acc, buildResult -> getVotingScore(acc, buildResult)
        }
        gerrit.applyVerificationLabel(verificationScore)

        def combinedScore = Builds.resultCodeStyle ?
            getVotingScore(verificationScore, Builds.resultCodeStyle) : verificationScore

        switch(combinedScore) {
            case 0: currentBuild.rawBuild.result = Result.ABORTED
                    break
            case 1: currentBuild.rawBuild.result = Result.SUCCESS
                    break
            case -1: currentBuild.rawBuild.result = Result.FAILURE
                    break
        }
    }
}
