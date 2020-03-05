#!/usr/bin/env groovy

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

import groovy.json.JsonSlurper
import groovy.json.JsonOutput

lintOutTrimmed = ""

def needsDockerBuild() {
    def queryUrl = "https://gerrit-review.googlesource.com/changes/${env.GERRIT_CHANGE_NUMBER}/revisions/${env.GERRIT_PATCHSET_REVISION}/files/"
    def response = httpRequest queryUrl
    def files = response.getContent().substring(5)
    def filesJson = new JsonSlurper().parseText(files)
    return filesJson.keySet().find { it.contains("docker") }
}

node ('master') {
  gerritReview labels: ['Code-Style': 0]

  stage('YAML lint') {
    node ('python3') {
      checkout scm
      def lintOut = sh(script: 'yamllint -c yamllint-config.yaml jenkins/*.yaml || true', returnStdout: true)
      lintOutTrimmed = lintOut.trim()
    }
  }

  stage('Code Style') {
    if (lintOutTrimmed) {
      gerritReview labels: ['Code-Style': -1], message: "${lintOutTrimmed}\n${env.BUILD_URL}"
    } else {
      gerritReview labels: ['Code-Style': 1], message: env.BUILD_URL
    }
  }

  if (needsDockerBuild()) {
    stage('Docker build') {
      node ('docker')
      try {
        sh "make -C jenkins-docker"
        gerritReview labels: ['Verified': 1], message: "Docker build OK\n${env.BUILD_URL}"
      } catch (e) {
        gerritReview labels: ['Verified': -1], message: "Docker build FAILED\n${env.BUILD_URL}"
      }
    }
  }
}
