        pipeline {
            options { skipDefaultCheckout true }
            agent { label 'bazel-debian' }
            stages {
                stage('Checkout') {
                    steps {
                        sh "git clone -b stable-3.12 --recursive https://gerrit.googlesource.com/gerrit"
                        sh "cd gerrit git config user.name jenkins && git config user.email jenkins@gerritforge.com"
                    }

                }
                stage('build') {
                    steps {
                        dir ('gerrit') {
                            sh "cd modules/jgit && git checkout servlet-4 && cd ../../"
                            sh "bazelisk build release"
                        }
                    }
            }
        }
            post {
                success {
                    gerritReview labels: [Verified: 1]
                }
                unstable {
                    gerritReview labels: [Verified: -1]
                }
                failure {
                    gerritReview labels: [Verified: -1]
                }
            }
        }
