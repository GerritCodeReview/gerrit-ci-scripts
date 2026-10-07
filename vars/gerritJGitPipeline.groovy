#!/usr/bin/env groovy

// Copyright (C) 2026 The Android Open Source Project
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

/**
 * Declarative pipeline for building and testing JGit changes with Bazel.
 *  Parameters: None
 * Usage in a Jenkinsfile:
 *   gerritJGitPipeline()
 */

def call(Map cfg = [:]) {

  echo "Starting pipeline for JGit master"
  echo "Change : ${env.GERRIT_CHANGE_NUMBER}/${env.GERRIT_PATCHSET_NUMBER} '${env.GERRIT_CHANGE_SUBJECT}'"
  echo "Change URL: ${env.GERRIT_CHANGE_URL}"

  pipeline {
    agent { label 'bazel-debian' }
    options {
      skipDefaultCheckout true
    }
    stages {
      stage('Checkout JGit') {
        steps {
          dir('jgit') {
            checkout scm
          }
        }
      }
      stage('Build JGit') {
        steps {
          dir('jgit') {
            sh '''#!/bin/bash -e
              . set-java.sh 25
              java -version
              bazelisk build all
            '''
          }
        }
      }
      stage('Test JGit') {
        steps {
          dir('jgit') {
            sh '''#!/bin/bash -e
              . set-java.sh 25
              bazelisk test //...
            '''
          }
        }
      }
    }

    post {
      success {
        gerritReview labels: ["Code-Review": 1], message: "JGit Bazel build and tests passed.\nBuild: ${env.BUILD_URL}"
      }
      unstable {
        gerritReview labels: ["Code-Review": -1], message: "JGit Bazel build or tests are unstable.\nBuild: ${env.BUILD_URL}"
      }
      failure {
        gerritReview labels: ["Code-Review": -1], message: "JGit Bazel build or tests failed.\nBuild: ${env.BUILD_URL}"
      }
    }
  }
}
