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

pipeline {
    agent { label 'gerrit-release-bazel' }

    parameters {
        password(name: 'GCLOUD_AUTH_TOKEN', defaultValue: '', description: "Gcloud Auth token obtained via 'gcloud auth login' and then 'gcloud auth print-access-token'")
        password(name: 'GPG_PASSPHRASE', defaultValue: '', description: "GPG key passphrase")
        string(name: 'VERSION',           defaultValue: '', description: 'Gerrit semantic release number')
        string(name: 'BRANCH',            defaultValue: '', description: 'Gerrit branch name where the release must be cut')
        string(name: 'NEXT_VERSION',      defaultValue: '', description: 'Next SNAPSHOT version after release')
        string(name: 'MIGRATION_VERSION', defaultValue: '', description: 'Test migration from an earlier Gerrit version')
    }
    environment {
        GCLOUD_AUTH_TOKEN = "${params.GCLOUD_AUTH_TOKEN}"
    }
    stages {

        stage('Gerrit Release') {
            steps {
                withCredentials([
                        usernamePassword(
                                credentialsId: 'ossrh-staging-api.central.sonatype.com',
                                usernameVariable: 'OSSHR_USER',
                                passwordVariable: 'OSSHR_TOKEN'
                        ),
                        usernamePassword(
                                credentialsId: 'gerrit.googlesource.com',
                                usernameVariable: 'GS_GIT_USER',
                                passwordVariable: 'GS_GIT_PASS'
                        ),
                        string(credentialsId: 'gpg-key',     variable: 'GPG_KEY'),
                ]) {
                    sh "gerrit-release.sh ${params.BRANCH} ${params.VERSION} ${params.NEXT_VERSION} ${params.MIGRATION_VERSION}"
                }
            }
        }

        stage('Confirm and push tag') {
            steps {
                dir('gerrit') {
                    script {
                        timeout(time: 5, unit: 'HOURS') {
                            input message: "Push tag v${params.VERSION} to origin (including submodules)?", ok: 'Yes, push'
                        }
                        sh '''
                            TAG="v${VERSION}"
                            echo "Pushing ${TAG} to origin..."
                            git push origin "${TAG}"
                            echo "Pushing ${TAG} to submodules (ignore failures)..."
                            git submodule foreach bash -c 'git push origin '"${TAG}"' || true'
                        '''
                    }
                }
            }
        }
    }
}
