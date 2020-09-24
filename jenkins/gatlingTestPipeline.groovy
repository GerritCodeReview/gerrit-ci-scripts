def accountCookie = ''
def xsrfToken = ''

pipeline {
        agent { label 'aws' }

        parameters {
            string(name: 'AWS_PREFIX', defaultValue:"jenkins", description: 'A string to prefix stacks and resources with')
            string(name: 'AWS_REGION', defaultValue:"us-east-1", description: 'Which region to deploy to')

            string(name: 'HOSTED_ZONE_NAME', description: 'Name of the hosted zone')
            string(name: 'CLUSTER_INSTANCE_TYPE', defaultValue: 'm4.xlarge', description:'The EC2 instance Type used to run the cluster')

            string(name: 'DOCKER_REGISTRY_URI', description: 'URI of the Docker registry')
            string(name: 'SSL_CERTIFICATE_ARN', description: 'ARN of the wildcard SSL Certificate')

            string(name: 'METRICS_CLOUDWATCH_NAMESPACE', defaultValue: 'jenkins', description: 'The CloudWatch namespace for Gerrit metrics')
            string(name: 'SUBDOMAIN', defaultValue: '$(AWS_PREFIX)-master-demo', description: 'Name of the master sub domain')
            string(name: 'GERRIT_KEY_PREFIX', defaultValue: 'gerrit_secret', description: 'Secrets prefix')

            string(name: 'GERRIT_HTTP_URL', description: 'Gerrit GUI URL')
            string(name: 'GERRIT_SSH_URL', description: 'Gerrit SSH URL')
            string(name: 'GIT_HTTP_USERNAME', description: 'Username for Git/HTTP testing')
            string(name: 'GIT_HTTP_PASSWORD', description: 'Password for Git/HTTP testing')
            string(name: 'GERRIT_PROJECT', defaultValue: 'load-test', description: 'Gerrit project for load test')
            string(name: 'NUM_USERS', defaultValue: '10', description: 'Number of concurrent user sessions')
            string(name: 'DURATION', defaultValue: '2 minutes', description: 'Total duration of the test')
        }
        stages{
            stage("Setup single-master aws stack") {
                steps {
                    withCredentials([usernamePassword(usernameVariable: "GS_GIT_USER", passwordVariable: "GS_GIT_PASS", credentialsId: env.GERRIT_CREDENTIALS_ID)]) {
                        sh 'echo "machine gerrit.googlesource.com login $GS_GIT_USER password $GS_GIT_PASS">> ~/.netrc'
                        sh 'chmod 600 ~/.netrc'
                        sh 'rm -rf aws-gerrit'
                        sh "git clone -b master https://gerrit.googlesource.com/aws-gerrit"
                        sh "cd aws-gerrit && git fetch origin master && git config user.name jenkins && git config user.email jenkins@gerritforge.com && git merge FETCH_HEAD"
                     }
                    dir ('aws-gerrit/gerrit/etc') {
                        script {
                            def gerritConfig = readFile(file:"gerrit.config.template")
                            gerritConfig = gerritConfig.replace("type = ldap","type = DEVELOPMENT_BECOME_ANY_ACCOUNT")
                            gerritConfig = gerritConfig.replace("smtpUser = {{ SMTP_USER }}\n    enable = true","smtpUser = {{ SMTP_USER }}\n    enable = false")

                            writeFile(file:"gerrit.config.template", text: gerritConfig)
                        }
                    }
                    withCredentials([usernamePassword(usernameVariable: "AWS_ACCESS_KEY_ID",
                    passwordVariable: "AWS_SECRET_ACCESS_KEY",
                    credentialsId: "aws-credentials-id")]) {
                        dir ('aws-gerrit/single-master') {
                            script {
                                def setupData = readFile(file:"setup.env.template")
                                setupData = resolveParameter(setupData, "HOSTED_ZONE_NAME", HOSTED_ZONE_NAME)
                                setupData = resolveParameter(setupData, "CLUSTER_INSTANCE_TYPE", CLUSTER_INSTANCE_TYPE)
                                setupData = resolveParameter(setupData, "DOCKER_REGISTRY_URI", DOCKER_REGISTRY_URI)
                                setupData = resolveParameter(setupData, "SSL_CERTIFICATE_ARN", SSL_CERTIFICATE_ARN)

                                setupData = resolveParameter(setupData, "METRICS_CLOUDWATCH_NAMESPACE",METRICS_CLOUDWATCH_NAMESPACE)
                                setupData = resolveParameter(setupData, 'SUBDOMAIN', SUBDOMAIN)

                                setupData = setupData + "\nGERRIT_KEY_PREFIX:= ${GERRIT_KEY_PREFIX}"

                                writeFile(file:"setup.env", text: setupData)
                            }
                            sh "make AWS_REGION=${AWS_REGION} AWS_PREFIX=${AWS_PREFIX} create-all"
                         }
                     }
                }
            }
            stage('Extract Gatling test user credentials from Gerrit') {
                steps {
                    retry(50) {
                        sleep(10)
                        sh "curl --fail -L -I '${GERRIT_HTTP_URL}' 2>/dev/null"
                    }
                    sh "curl -L -c cookies -i -X POST '${GERRIT_HTTP_URL}/login/%2Fq%2Fstatus%3Aopen%2B-is%3Awip?account_id=1000000'"
                    script {
                        def cookies = readFile(file:"cookies")
                        def cookiesMap = cookies
                            .split('\n')
                            .findAll{it.contains('GerritAccount') || it.contains('XSRF_TOKEN')}
                            .inject([:]) { map, token ->
                                def tokens = token.split('\t')
                                map[tokens[5].trim()] = tokens[6].trim()
                                map
                            }

                        accountCookie = cookiesMap['GerritAccount']
                        xsrfToken = cookiesMap['XSRF_TOKEN']
                    }
                }
            }
            stage('Pull newest Gatling tests docker image') {
                steps {
                    sh 'docker pull gerritforge/gatling-sbt-gerrit-test'
                }
            }

            stage('Run Gatling tests') {
                steps {
                    script {
                        writeFile(file:"simulation.env", text: """
                                GERRIT_HTTP_URL=${GERRIT_HTTP_URL}
                                GERRIT_SSH_URL=${GERRIT_SSH_URL}
                                ACCOUNT_COOKIE=${accountCookie}
                                GIT_HTTP_USERNAME=${GIT_HTTP_USERNAME}
                                GIT_HTTP_PASSWORD=${GIT_HTTP_PASSWORD}
                                XSRF_TOKEN=${xsrfToken}
                                GERRIT_PROJECT=${GERRIT_PROJECT}
                                GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
                           """)
                    }
                    sh "mkdir -p ${WORKSPACE}/results"
                    // If Jenkins agent uses Docker remote server mounting local directory will mount directory
                    // from Docker server host not agent host. Gatling reports will not be visible in build workspace.
                    // Use Docker volume to avoid this situation.
                    sh "docker volume create gatling-results"
                    script {
                        for (simulation in ["GerritGitSimulation", "GerritRestSimulation"]) {
                            sh """\
                                docker run --rm --env-file simulation.env -v gatling-results:/opt/gatling/results \
                                gerritforge/gatling-sbt-gerrit-test -s gerritforge.${simulation}
                               """
                        }
                    }
                    //Copy data from Docker volume to Jenkins build workspace
                    sh "docker create -v gatling-results:/data --name gatling-results-container busybox true"
                    sh "docker cp gatling-results-container:/data/. ${WORKSPACE}/results/"
                    // Clean up
                    sh "docker rm gatling-results-container"
                    sh "docker volume rm gatling-results"

                    gatlingArchive()
                }
            }

        }
        post {
            cleanup {
                withCredentials([usernamePassword(usernameVariable: "AWS_ACCESS_KEY_ID", 
                    passwordVariable: "AWS_SECRET_ACCESS_KEY",
                    credentialsId: "aws-credentials-id")]) {
                        dir ('aws-gerrit/single-master') {
                            sh "make AWS_REGION=${AWS_REGION} AWS_PREFIX=${AWS_PREFIX} delete-all"
                        }
                }
            }
        }
}

def resolveParameter(String text, String paramName, String paramValue) {
    return text.split('\n').collect { l ->
        def targetLine = l.trim().startsWith(paramName)
        targetLine ? "${paramName}:=${paramValue}" : l
    }.join('\n')
}