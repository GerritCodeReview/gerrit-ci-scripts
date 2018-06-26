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

verbose = true

String.metaClass.encodeURL = {
    java.net.URLEncoder.encode(delegate)
}

class Config {
    static String gerrit = "https://gerrit-review.googlesource.com/"
    static long curlTimeout = 10000
    static int waitForResultTimeout = 10000
    static Map buildsList = [:]

    static def ciTag(String operation) {
        " \"tag\" : \"autogenerated:gerrit-ci:${operation}\" "
    }

    static String addVerifiedTag = ciTag("addVerified")
    static Set<String> codeStyleBranches = ["master", "stable-2.14", "stable-2.15"]
    static resTicks = [ 'ABORTED':'\u26aa', 'SUCCESS':'\u2705', 'FAILURE':'\u274c' ]
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

def postToGerrit(url, jsonPayload) {
    def error = ""
    def gerritPostUrl = Config.gerrit + url
    def curl = ['curl',
    '-n', '-s', '-S',
    '-X', 'POST', '-H', 'Content-Type: application/json',
    '--data-binary', jsonPayload,
        gerritPostUrl ]
    if(verbose) { println "CURL/EXEC> ${curl}" }
    def proc = curl.execute()
    def sout = new StringBuffer(), serr = new StringBuffer()
    proc.consumeProcessOutput(sout, serr)
    proc.waitForOrKill(Config.curlTimeout)
    def curlExit = proc.exitValue()
    if(curlExit != 0) {
        error = "${curl} **FAILED** with exit code = ${curlExit}"
        println error
        throw new IOException(error)
    }

    if(!sout.toString().trim().isEmpty() && verbose) {
        println "CURL/OUTPUT> ${sout}"
    }
    if(!serr.toString().trim().isEmpty() && verbose) {
        println "CURL/ERROR> ${serr}"
    }

    return 0
}

def applyVerificationLabel(verified, builds) {
    if(verified == 0) {
        return;
    }

    def msgList = builds.collect { type,build ->
        [ 'type': type, 'res': build.getResult().toString(),
            'url': build.getBuildUrl() + "consoleText" ]
    } sort { a,b -> a['res'].compareTo(b['res']) }

    def msgBody = msgList.collect {
        "${Config.resTicks[it.res]} ${it.type} : ${it.res}\n    (${it.url})"
    } .join('\n')

    def addVerifiedExit = generateAndPostLabelJson('Verified', verified, msgBody)
    if(addVerifiedExit == 0) {
        println "----------------------------------------------------------------------------"
        println "Gerrit Review: Verified=${verified} to change ${Change.changeJson._number}/${Change.sha1}"
        println "----------------------------------------------------------------------------"
    }

    return addVerifiedExit
}

def findCodestyleFilesInLog(build) {
    def codestyleFiles = []
    def needsFormatting = false
    def codestyleLogReader = build.getLogReader()
    codestyleLogReader.eachLine {
        needsFormatting = needsFormatting || (it ==~ /.*Need Formatting.*/)
        if(needsFormatting && it ==~ /\[.*\]/) {
        codestyleFiles += it.substring(1,it.length()-1)
        }
    }

    return codestyleFiles
}

def applyCodestyleLabel(cs, files, build) {
    if(cs == 0) {
        return
    }

    def formattingMsg = cs < 0 ? ('The following files need formatting:\n    ' +
        files.join('\n    ')) : 'All files are correctly formatted'
    def res = build.getResult().toString()
    def url = build.getBuildUrl() + "consoleText"

    def msgBody = "${Config.resTicks[res]} ${formattingMsg}\n    (${url})"

    def addCodeStyleExit = generateAndPostLabelJson('Code-Style', cs, msgBody)
    if(addCodeStyleExit == 0) {
        println "----------------------------------------------------------------------------"
        println "Gerrit Review: Code-Style=${cs} to change ${Change.changeJson._number} / ${Change.sha1}"
        println "----------------------------------------------------------------------------"
    }

    return addCodeStyleExit
}

def generateAndPostLabelJson(label, score, msgBody = "") {
    def notify = score < 0 ? ', "notify" : "OWNER"' : ''
    def jsonPayload = '{"labels":{"' + label + '":' + score + '},' +
        ' "message": "' + msgBody + '"' +
        notify + ", ${Config.addVerifiedTag} }"

    return postToGerrit("a/changes/${Change.changeJson._number}/revisions/${Change.sha1}/review",
        jsonPayload)
}

def waitForResult(b) {
    def res = null
    def startWait = System.currentTimeMillis()
    while(res == null && (System.currentTimeMillis() - startWait) < Config.waitForResultTimeout) {
        res = b.getResult()
        if(res == null) {
            Thread.sleep(100) {
            }
        }
    }
    return res == null ? Result.FAILURE : res
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
        Config.gerrit, Change.changeNum, Change.sha1))
    def files = filesUrl.getText().substring(5)
    def filesJson = new JsonSlurper().parseText(files)
    filesJson.keySet().findAll { it != "/COMMIT_MSG" }
}

def formatBuildStep(buildName,mode,tool,retryTimes = 1) {
    def key = ""
    if (buildName == "Gerrit-codestyle"){
        key = "codestyle"
    } else {
        key = "${tool}/${mode}"
    }
    return [{
        retry (retryTimes) {
            Config.buildsList.put(key,
                build(buildName, REFSPEC: Change.ref, BRANCH: Change.sha1,
                    CHANGE_URL: Change.changeUrl, MODE: mode, TARGET_BRANCH: Change.branch))
            println "Builds status:"
            Config.buildsList.each {
                n, v -> println "  ${n} : ${v.getResult()}\n    (${v.getBuildUrl() + "consoleText"})"
            }
        }
    }]
}

def getWorkspace(){
    def workspace = build.environment.get("WORKSPACE")
    println "workspace: ${workspace}"
    def cwd = new File("${workspace}")
    println "cwd: ${cwd}"
    return cwd
}

def executeBash(cwd, command) {
    def sout = new StringBuilder(), serr = new StringBuilder()
    println "SH: ${command}"
    def shell = command.execute([],cwd)
    shell.consumeProcessOutput(sout, serr)
    shell.waitForOrKill(30000)
    println "OUT: ${sout}"
    println "ERR: ${serr}"
}

def initializeGit(cwd){
    executeBash(cwd, "git fetch origin ${Change.ref}")
    executeBash(cwd, "git checkout FETCH_HEAD")
    executeBash(cwd, "git fetch origin ${Change.branch}")
    executeBash(cwd, 'git config user.name "Jenkins Build"')
    executeBash(cwd, 'git config user.email "jenkins@gerritforge.com"')
    executeBash(cwd, 'git merge --no-commit --no-edit --no-ff FETCH_HEAD')
}

def collectBuildTool(cwd){
    def tool = ""
    if(new java.io.File("${cwd}/BUCK").exists()) {
        tool = "buck"
    } else if(new java.io.File("${cwd}/BUILD").exists()) {
        tool = "bazel"
    }
    return tool
}

def collectBuildModes(){
    def modes = ["reviewdb"]
    if(Change.branch == "master" || Change.branch == "stable-2.15") {
        modes += "notedb"
    }

    if(Change.branch == "master" || Change.branch == "stable-2.15" ||
        Change.branch == "stable-2.14") {
        def changedFiles = getChangedFiles()
        def polygerritFiles = changedFiles.findAll { it.startsWith("polygerrit-ui") }

        if(polygerritFiles.size() > 0) {
            if(changedFiles.size() == polygerritFiles.size()) {
                println "Only PolyGerrit UI changes detected, skipping other test modes..."
                modes = ["polygerrit"]
            } else {
                println "PolyGerrit UI changes detected, adding 'polygerrit' validation..."
                modes += "polygerrit"
            }
        }
    }
    return modes
}

def buildChange() {
    def cwd = getWorkspace()
    initializeGit(cwd)
    def tool = collectBuildTool(cwd)
    def modes = collectBuildModes()

    println "Building Change " + Change.changeUrl
    build.setDescription("""<a href='${Change.changeUrl}' target='_blank'>Change #${Change.changeNum}</a>""")

    def builds = []
    if (Config.codeStyleBranches.contains(Change.branch)){
        builds += formatBuildStep("Gerrit-codestyle", "reviewdb", tool)
    }
    println "Running validation jobs using ${tool} builds for ${modes} ..."
    def buildName = "Gerrit-verifier-${tool}"
    modes.collect {
        formatBuildStep(buildName,it,tool)
    }.each { builds += it }

    def buildsWithResults = buildJobsInParallel(builds)
    def codestyleResult = buildsWithResults.find{ it[0] == "codestyle" }
    if(codestyleResult) {
        def resCodeStyle = getVotingScore(1, codestyleResult[1])
        def codestyleBuild = Config.buildsList["codestyle"]
        applyCodestyleLabel(resCodeStyle, findCodestyleFilesInLog(codestyleBuild), codestyleBuild)
    }

    flaky = findFlakyBuilds(buildsWithResults.findAll { it[0] != "codestyle" })
    if(flaky.size > 0) {
        println "** FLAKY Builds detected: ${flaky}"
        buildsWithResults = retryFlakyBuilds(flaky)
    }

    def resVerify = buildsWithResults.findAll{ it != codestyleResult }.inject(1) { acc, buildResult ->
        getVotingScore(acc, buildResult[1]) }

    def resAll = codestyleResult ? getVotingScore(resVerify, codestyleResult[1]) : resVerify

    applyVerificationLabel(resVerify, Config.buildsList.findAll { key,build -> key != "codestyle" })

    switch(resAll) {
        case 0: build.state.result = ABORTED
            break
        case 1: build.state.result = SUCCESS
            break
        case -1: build.state.result = FAILURE
            break
    }
}

def buildJobsInParallel(builds) {
    ignore(FAILURE) {
        parallel (builds)
    }
    def results = Config.buildsList.values().collect { waitForResult(it) }
    def buildsWithResults = []

    Config.buildsList.keySet().eachWithIndex {
        key,index -> buildsWithResults.add(new Tuple(key, results[index]))
    }
    return buildsWithResults
}

def findFlakyBuilds(buildsWithResults) {
    def flaky = buildsWithResults.findAll { it[1] == null || it[1] != SUCCESS }
    if(flaky.size == buildsWithResults.size) {
        return []
    }

    return flaky.collect { it[0] }
}

def retryFlakyBuilds(flaky){
    def retryBuilds = []
    def toolsAndModes = flaky.collect { it.split("/") }

    toolsAndModes.each {
        def tool = it[0]
        def mode = it[1]
        def buildName = "Gerrit-verifier-$tool"
        Config.buildsList.remove(it)
        retryBuilds += formatBuildStep(buildName,mode,tool,3)
    }
    return buildJobsInParallel(retryBuilds)
}

def fetchChange(){
    def requestedChangeId = params.get("CHANGE_ID")
    def queryUrl =
        new URL("${Config.gerrit}changes/${requestedChangeId}/?pp=0&O=3")
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
    Change.changeUrl = Config.gerrit + "#/c/" + Change.changeNum +
        "/" + Change.patchNum
}

fetchChange()
extractChangeMetaData()

if(Change.sha1 == null) {
    println "[WARNING] Skipping change ${Change.changeJson.change_id}" +
        " because it does not have any current revision or patch-set"
} else {
    buildChange()
}

