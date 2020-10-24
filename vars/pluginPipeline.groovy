#!/usr/bin/env groovy

// Copyright (C) 2020 The Android Open Source Project
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

// Declarative pipeline for building and testing a Gerrit plugin.
// Parameters:
// - name (optional): plugin name
// - formatCheckId (optional): check-id for code-style validation
// - buildCheckId (optional): check-id for build validation
//
// Minimalistic Jenkinsfile example (no checks):
// pluginPipeline()
//
// Jenkinsfile example with code-style and build checks:
// pluginPipeline(formatCheckId: 'myscheme:myformatcheckid', buildCheckId: 'myscheme:mybuildcheckid')
//
// P.S. The plugin project must have the corresponding checkers configured using
//      the Gerrit Checks GUI or API. The minimalistic example does not require any
//      checkers.

def call(Map parm = [:]) {
    def pluginName = parm.name ?: "${env.GERRIT_PROJECT}".split('/').last()
    def formatCheck = parm.formatCheckId
    def buildCheck = parm.buildCheckId
    def pluginScmUrl = "https://gerrit.googlesource.com/a/${env.GERRIT_PROJECT}"
    def gjfVersion = '1.7'
    def javaVersion = 11
    if (["stable-2.16", "stable-3.0", "stable-3.1", "stable-3.2"].contains("${env.GERRIT_BRANCH}")) {
        javaVersion = 8
    }
    def bazeliskCmd = ". set-java.sh ${javaVersion} && bazelisk"

    echo "Starting pipeline for plugin '${pluginName}'" + (formatCheck ? " formatCheckId=${formatCheck}" : '') + (buildCheck ? " buildCheckId=${buildCheck}" : '')
    echo "Change : ${env.GERRIT_CHANGE_NUMBER}/${GERRIT_PATCHSET_NUMBER} '${env.GERRIT_CHANGE_SUBJECT}'"
    echo "Change URL: ${env.GERRIT_CHANGE_URL}"

    pipeline {
        options { skipDefaultCheckout true }
        agent { label 'bazel-debian' }
        stages {
            stage('Checkout') {
                steps {
                    withCredentials([usernamePassword(usernameVariable: "GS_GIT_USER", passwordVariable: "GS_GIT_PASS", credentialsId: env.GERRIT_CREDENTIALS_ID)]) {
                        sh 'echo "machine gerrit.googlesource.com login $GS_GIT_USER password $GS_GIT_PASS">> ~/.netrc'
                        sh 'chmod 600 ~/.netrc'
                        sh "git clone -b ${env.GERRIT_BRANCH} ${pluginScmUrl}"
                        sh "cd ${pluginName} && git fetch origin refs/changes/${BRANCH_NAME} && git config user.name jenkins && git config user.email jenkins@gerritforge.com && git merge FETCH_HEAD"
                    }
                }
            }
            stage('Formatting') {
                when {
                    expression { formatCheck }
                }
                steps {
                    gerritCheck (checks: ["${formatCheck}": 'RUNNING'], url: "${env.BUILD_URL}console")
                    sh "find ${pluginName} -name '*.java' | xargs /home/jenkins/format/google-java-format-${gjfVersion} -i"
                    script {
                        def formatOut = sh (script: "cd ${pluginName} && git status --porcelain", returnStdout: true)
                        if (formatOut.trim()) {
                            def files = formatOut.split('\n').collect { it.split(' ').last() }
                            files.each { gerritComment path:it, message: 'Needs reformatting with GJF' }
                            gerritCheck (checks: ["${formatCheck}": 'FAILED'], url: "${env.BUILD_URL}console")
                        } else {
                            gerritCheck (checks: ["${formatCheck}": 'SUCCESSFUL'], url: "${env.BUILD_URL}console")
                        }
                    }
                }
            }
            stage('build') {
                environment {
                    DOCKER_HOST = """${sh(
                         returnStdout: true,
                         script: "/sbin/ip route|awk '/default/ {print  \"tcp://\"\$3\":2375\"}'"
                     )}"""
            }
                steps {
                    script { if (buildCheck) { gerritCheck (checks: ["${buildCheck}": 'RUNNING'], url: "${env.BUILD_URL}console") } }
                    sh 'git clone --recursive -b $GERRIT_BRANCH https://gerrit.googlesource.com/gerrit'
                    dir ('gerrit') {
                        sh "cd plugins && ln -s ../../${pluginName} ."
                        sh "if [ -f ../${pluginName}/external_plugin_deps.bzl ]; then cd plugins && ln -sf ../../${pluginName}/external_plugin_deps.bzl .; fi"
                        sh "if [ -f ../${pluginName}/package.json ]; then cd plugins && ln -sf ../../${pluginName}/package.json .; fi"
                        sh "${bazeliskCmd} build plugins/${pluginName}"
                        sh "${bazeliskCmd} test --test_env DOCKER_HOST=" + '$DOCKER_HOST' + " plugins/${pluginName}/..."
                    }
                }
        }
    }
        post {
            success {
                script { if (buildCheck) { gerritCheck (checks: ["${buildCheck}": 'SUCCESSFUL'], url: "${env.BUILD_URL}console") } }
                gerritReview labels: [Verified: 1]
            }
            unstable {
                script { if (buildCheck) { gerritCheck (checks: ["${buildCheck}": 'FAILED'], url: "${env.BUILD_URL}console") } }
                gerritReview labels: [Verified: -1]
            }
            failure {
                script { if (buildCheck) { gerritCheck (checks: ["${buildCheck}": 'FAILED'], url: "${env.BUILD_URL}console") } }
                gerritReview labels: [Verified: -1]
            }
        }
    }
}
