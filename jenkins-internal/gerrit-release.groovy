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

// TODO: This is missing other required credentials

pipeline {
    agent { label 'bazel-bookworm-release' }

    parameters {
        password(name: 'GCLOUD_AUTH_TOKEN', defaultValue: '', description: "Gcloud Auth token obtained via 'gcloud auth login'")
        string(name: 'VERSION', defaultValue: '', description: 'Gerrit semantic release number')
        string(name: 'BRANCH', defaultValue: '', description: 'Gerrit branch name where the release must be cut')
        string(name: 'NEXT_VERSION', defaultValue: '', description: 'Next SNAPSHOT version after release')
        string(name: 'MIGRATION_VERSION', defaultValue: '', description: 'Test migration from an earlier Gerrit version')
    }

    stages {
        stage("Gerrit Release") {
            steps {
                sh "gerrit-release.sh ${params.BRANCH} ${params.VERSION} ${params.NEXT_VERSION} ${params.MIGRATION_VERSION} ${params.GCLOUD_AUTH_TOKEN}"
            }
        }
    }
}
