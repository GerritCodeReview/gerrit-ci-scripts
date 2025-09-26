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
        password(name: 'GCLOUD_AUTH_TOKEN', defaultValue: '', description: "Gcloud Auth token obtained via 'gcloud auth login' and then 'gcloud print-access-token'")
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
                                passwordVariable: 'OSSHR_PASSWORD'
                        )
                ]) {
                    sh '''
                        umask 077
                        mkdir -p "$HOME/.m2"
                        cat > "$HOME/.m2/settings.xml" <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>OSSRH-staging</id>
      <username>${OSSHR_USER}</username>
      <password>${OSSHR_PASSWORD}</password>
    </server>
  </servers>
</settings>
EOF
          '''
                }

                withCredentials([
                        usernamePassword(
                                credentialsId: 'ossrh-staging-api.central.sonatype.com',
                                usernameVariable: 'OSSHR_USER',
                                passwordVariable: 'OSSHR_PASSWORD'
                        ),
                        file(credentialsId: 'gitcookies',      variable: 'GITCOOKIES'),
                        file(credentialsId: 'gitconfig',       variable: 'GITCONFIG_TMPL'),
                        file(credentialsId: 'gpg_private',     variable: 'GPG_KEY'),
                        file(credentialsId: 'gpg_passphrase',  variable: 'GPG_PASSPHRASE_FILE')
                ]) {
                    sh "gerrit-release.sh ${params.BRANCH} ${params.VERSION} ${params.NEXT_VERSION} ${params.MIGRATION_VERSION}"
                }
            }
        }
    }
}