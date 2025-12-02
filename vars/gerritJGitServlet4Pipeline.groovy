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
 * Declarative pipeline for building and testing JGit servlet-4 branch against Gerrit stable-3.13 and Gerrit master.
 *  Parameters: None
 * Usage in a Jenkinsfile:
 *   gerritJGitServlet4Pipeline()
 */

def call(Map cfg = [:]) {

  echo "Starting pipeline for JGit servlet-4"
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
              . set-java.sh 21
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
              . set-java.sh 21
              bazelisk test //...
            '''
          }
        }
      }

      stage('Checkout Gerrit stable-3.13') {
        steps {
          sh '''
            git clone -b stable-3.13 --recursive https://gerrit.googlesource.com/gerrit
          '''
        }
      }

      stage('Build Gerrit stable-3.13') {
        steps {
          script {
            def jgitSourceDir = "${env.WORKSPACE}/jgit"
            def jgitTargetDir = "${env.WORKSPACE}/gerrit/modules/jgit"
            echo "Replacing gerrit jgit module with jgit change ${env.GERRIT_CHANGE_NUMBER}..."

            sh """
                echo "${jgitSourceDir} -> ${jgitTargetDir}"
                mv ${jgitTargetDir} /tmp/jgit-3.13
                ln -sfn ${jgitSourceDir} ${jgitTargetDir}
            """

            dir('gerrit') {
              sh '''
                . set-java.sh 21
                  bazelisk build release
              '''
            }
          }
        }
      }
      stage('Test Gerrit stable-3.13') {
        steps {
          dir('gerrit') {
            sh '''
              . set-java.sh 21
              echo "running gerrit stable-3.13 tests..."
              bazelisk test \
                --test_tag_filters=-flaky \
                --flaky_test_attempts 3 \
                --test_timeout 3600 \
                //...
            '''
          }
        }
      }
      stage('Checkout Gerrit master') {
        steps {
          dir('gerrit') {
            sh '''
              git reset --hard origin/master
              git checkout master
              git submodule update --init --recursive
            '''
          }
        }
      }
      stage('Build Gerrit master') {
        steps {
          script {
            def jgitSourceDir = "${env.WORKSPACE}/jgit"
            def jgitTargetDir = "${env.WORKSPACE}/gerrit/modules/jgit"
            echo "Replacing gerrit jgit module with jgit change ${env.GERRIT_CHANGE_NUMBER}..."

            sh """
                echo "${jgitSourceDir} -> ${jgitTargetDir}"
                mv ${jgitTargetDir} /tmp/jgit-master
                ln -sfn ${jgitSourceDir} ${jgitTargetDir}
            """

            dir('gerrit') {
              sh """
                . set-java.sh 21
                bazelisk build release
              """
            }
          }
        }
      }
      stage('Test Gerrit master') {
        steps {
          dir('gerrit') {
            sh '''
              . set-java.sh 21
              echo "running gerrit master tests..."
              bazelisk test \
                --test_tag_filters=-flaky \
                --flaky_test_attempts 3 \
                --test_timeout 3600 \
                //...
            '''
          }
        }
      }
    }

    post {
      success {
        gerritReview labels: ["Code-Review": 1], message: "Gerrit successfully builds with this JGit change.\nBuild: ${env.BUILD_URL}"
      }
      unstable {
        gerritReview labels: ["Code-Review": -1], message: "Gerrit build with this JGit change is unstable.\nBuild: ${env.BUILD_URL}"
      }
      failure {
        gerritReview labels: ["Code-Review": -1], message: "Gerrit does not build successfully with this JGit change.\nBuild: ${env.BUILD_URL}"
      }
    }
  }
}
