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
    agent { label 'bazel-bookworm-release' }

    parameters {
        password(name: 'GCLOUD_AUTH_TOKEN', defaultValue: '', description: "Gcloud Auth token obtained via gcloud auth login and then gcloud autifconh print-access-token")
        string(name: 'VERSION', defaultValue: '', description: 'Gerrit semantic release number')
        string(name: 'BRANCH', defaultValue: '', description: 'Gerrit branch name where the release must be cut')
        string(name: 'NEXT_VERSION', defaultValue: '', description: 'Next SNAPSHOT version after release')
        string(name: 'MIGRATION_VERSION', defaultValue: '', description: 'Test migration from an earlier Gerrit version')
    }

    stages {
        stage("Gerrit Release") {
            steps {
                withCredentials([
                        usernamePassword(usernameVariable: "OSSHR_USER", passwordVariable: "OSSHR_PASSWORD", credentialsId: "ossrh-staging-api.central.sonatype.com"),
                        file(credentialsId: 'gitcookies',   variable: 'GITCOOKIES'),
                        file(credentialsId: 'gitconfig',    variable: 'GITCONFIG_TMPL'),
                        file(credentialsId: 'gpg_private',  variable: 'GPG_KEY'),
                        string(credentialsId: 'gpg_passphrase', variable: 'GPG_PASSPHRASE'),
                        string(credentialsId: 'gcloud_token', variable: 'GCLOUD_AUTH_TOKEN')
                ]) {
                sh "gerrit-release.sh ${params.BRANCH} ${params.VERSION} ${params.NEXT_VERSION} ${params.MIGRATION_VERSION} ${params.GCLOUD_AUTH_TOKEN}"
            }
        }
    }
}
