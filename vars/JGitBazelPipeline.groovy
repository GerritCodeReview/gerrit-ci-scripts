#!/usr/bin/env groovy

// Copyright (C) 2025 The Android Open Source Project
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
 * Declarative pipeline for building and testing JGit servlet-4 branch against Gerrit master.
 *  Parameters: None
 * Usage in a Jenkinsfile:
 *   gerritJGitServlet4Pipeline()
 */

def call(Map cfg = [:]) {

  echo "Starting pipeline for JGit"
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
            sh '''
              echo "Building JGit with Bazel..."
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
            sh '''
              echo "Running JGit tests..."
              . set-java.sh 25
              bazelisk test //...
            '''
          }
        }
      }
    }

    post {
      success {
        gerritReview labels: ["Code-Review": 1], message: "Works with Bazel!\nBuild: ${env.BUILD_URL}"
      }
      unstable {
        gerritReview labels: ["Code-Review": -1], message: "Some tests are failing :-(\nBuild: ${env.BUILD_URL}"
      }
      failure {
        gerritReview labels: ["Code-Review": -1], message: "Breaks the build.\nBuild: ${env.BUILD_URL}"
      }
    }
  }
}
