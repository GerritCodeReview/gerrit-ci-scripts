pipeline {
        agent { label 'bazel-debian' }
        parameters {
            string(name: 'GERRIT_HTTP_URL', description: 'Gerrit GUI URL')
            string(name: 'GERRIT_SSH_URL', description: 'Gerrit SSH URL')
            string(name: 'GIT_HTTP_USERNAME', description: 'Username for Git/HTTP testing')
            string(name: 'GIT_HTTP_PASSWORD', description: 'Password for Git/HTTP testing')
            string(name: 'GERRIT_PROJECT', defaultValue: 'load-test', description: 'Gerrit project for load test')
            string(name: 'ACCOUNT_COOKIE', description: 'HTTP Cookie to access the Gerrit GUI')
            string(name: 'XSRF_TOKEN', description: 'XSRF_TOKEN Cookie to access the Gerrit GUI for pOST operations')
            string(name: 'NUM_USERS', defaultValue: '10', description: 'Number of concurrent user sessions')
            string(name: 'DURATION', defaultValue: '2 minutes', description: 'Total duration of the test')

        }
        stages{
            stage('Pull newest Gatling tests docker image') {
                steps {
                    sh 'docker pull gerritforge/gatling-sbt-gerrit-test'
                }
            }

            stage('Run Gatling tests') {
                steps {
                    script {
                        writeFile(file:"simulation.env", text: """
                                GERRIT_HTTP_URL="${GERRIT_HTTP_URL}"
                                GERRIT_SSH_URL="${GERRIT_SSH_URL}"
                                ACCOUNT_COOKIE="${ACCOUNT_COOKIE}"
                                GIT_HTTP_USERNAME="${GIT_HTTP_USERNAME}"
                                GIT_HTTP_PASSWORD="${GIT_HTTP_PASSWORD}"
                                XSRF_TOKEN="${XSRF_TOKEN}"
                                GERRIT_PROJECT="${GERRIT_PROJECT}"
                                GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
                           """)
                    }
                    script {
                        for (simulation in ["GerritGitSimulation", "GerritRestSimulation"]) {
                            sh """\
                                docker run --rm --env-file simulation.env -v `pwd`/target/gatling:/opt/gatling/results \
                                gerritforge/gatling-sbt-gerrit-test -s gerritforge.${simulation}
                               """
                        }
                    }

                    gatlingArchive()
                }
            }
        }
}