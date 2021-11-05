def accountCookie = ''
def xsrfToken = ''
def epochTime = new Date().getTime()

pipeline {
        agent { label 'aws' }

        parameters {
            string(name: 'AWS_PREFIX', defaultValue:"jenkins", description: 'A string to prefix stacks and resources with')
            string(name: 'AWS_REGION', defaultValue:"us-east-1", description: 'Which region to deploy to')

            string(name: 'GERRIT_VERSION', defaultValue:"3.5", description: 'The gerrit version under test')
            string(name: 'GERRIT_PATCH', defaultValue:"0-rc1", description: 'The gerrit version patch under test')
            string(name: 'GERRIT_WAR_URL', defaultValue:"https://gerrit-ci.gerritforge.com/job/Gerrit-bazel-java11-stable-3.5/lastSuccessfulBuild/artifact/gerrit/bazel-bin/release.war", description: 'The gerrit.war URL to use as override of the gerrit version under test')

            string(name: 'HOSTED_ZONE_NAME', defaultValue: "gerritforgeaws.com", description: 'Name of the hosted zone')
            string(name: 'CLUSTER_INSTANCE_TYPE', defaultValue: 'm4.xlarge', description:'The EC2 instance Type used to run the cluster')

            string(name: 'DOCKER_REGISTRY_URI', defaultValue: '117385740707.dkr.ecr.$(AWS_REGION).amazonaws.com', description: 'URI of the Docker registry')
            string(name: 'SSL_CERTIFICATE_ARN', defaultValue: "arn:aws:acm:us-east-1:117385740707:certificate/33e2c235-a4d1-42b7-b866-18d8d744975c", description: 'ARN of the wildcard SSL Certificate')

            string(name: 'GERRIT_VOLUME_SNAPSHOT_ID', defaultValue: "snap-01c12c75ead9e9cd4", description: 'Id of the EBS volume snapshot')

            string(name: 'METRICS_CLOUDWATCH_NAMESPACE', defaultValue: 'jenkins', description: 'The CloudWatch namespace for Gerrit metrics')
            string(name: 'BASE_SUBDOMAIN', defaultValue: 'gerrit-demo', description: 'Name of the master sub domain')
            string(name: 'GERRIT_KEY_PREFIX', defaultValue: 'gerrit_secret', description: 'Secrets prefix')

            string(name: 'GERRIT_SSH_USERNAME', defaultValue: 'gerritadmin', description: 'Gerrit SSH username')
            string(name: 'GERRIT_SSH_PORT', defaultValue: '29418', description: 'Gerrit SSH port')

            string(name: 'GERRIT_HTTP_SCHEMA', defaultValue: 'https', description: 'Gerrit HTTP schema')
            string(name: 'GIT_HTTP_USERNAME', defaultValue: '', description: 'Username for Git/HTTP testing, use vault by default')
            password(name: 'GIT_HTTP_PASSWORD', defaultValue: '', description: 'Password for Git/HTTP testing, use vault by default')

            string(name: 'S3_EXPORT_LOGS_BUCKET_NAME', defaultValue: 'gerritforge-export-logs', description: 'S3 bucket to export logs to')

            string(name: 'GERRIT_PROJECT', defaultValue: 'load-test', description: 'Gerrit project for load test')
            string(name: 'NUM_USERS', defaultValue: '10', description: 'Number of concurrent user sessions')
            string(name: 'DURATION', defaultValue: '2 minutes', description: 'Total duration of the test')
        }

       environment {
            DOCKER_HOST = """${sh(
                returnStdout: true,
                script: '/sbin/ip route|awk \'/default/ {print "tcp://"\$3":2375"}\''
            )}"""
            HTTP_SUBDOMAIN = String.format("http-%s-%s.%s", "jenkins", epochTime, "${params.BASE_SUBDOMAIN}")
            SSH_SUBDOMAIN = String.format("ssh-%s-%s.%s", "jenkins", epochTime, "${params.BASE_SUBDOMAIN}")
            GERRIT_HTTP_URL = String.format("%s://%s.%s", "${params.GERRIT_HTTP_SCHEMA}", HTTP_SUBDOMAIN, "${params.HOSTED_ZONE_NAME}")
            GERRIT_SSH_URL = String.format("ssh://%s@%s.%s:%s", "${params.GERRIT_SSH_USERNAME}", SSH_SUBDOMAIN, "${params.HOSTED_ZONE_NAME}", "${params.GERRIT_SSH_PORT}")
         }

        stages{
            stage("Setup single-primary aws stack") {
                steps {
                    withCredentials([usernamePassword(usernameVariable: "GS_GIT_USER", passwordVariable: "GS_GIT_PASS", credentialsId: "gerrit.googlesource.com")]) {
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
                        dir ('aws-gerrit/single-primary') {
                            script {
                                def setupData = readFile(file:"setup.env.template")
                                setupData = resolveParameter(setupData, "HOSTED_ZONE_NAME", "${params.HOSTED_ZONE_NAME}")
                                setupData = resolveParameter(setupData, "CLUSTER_INSTANCE_TYPE", "${params.CLUSTER_INSTANCE_TYPE}")
                                setupData = resolveParameter(setupData, "DOCKER_REGISTRY_URI", "${params.DOCKER_REGISTRY_URI}")
                                setupData = resolveParameter(setupData, "SSL_CERTIFICATE_ARN", "${params.SSL_CERTIFICATE_ARN}")

                                setupData = resolveParameter(setupData, "METRICS_CLOUDWATCH_NAMESPACE", "${params.METRICS_CLOUDWATCH_NAMESPACE}")
                                setupData = resolveParameter(setupData, 'HTTP_SUBDOMAIN', "${env.HTTP_SUBDOMAIN}")
                                setupData = resolveParameter(setupData, 'SSH_SUBDOMAIN', "${env.SSH_SUBDOMAIN}")

                                setupData = setupData + "\nGERRIT_KEY_PREFIX:= ${params.GERRIT_KEY_PREFIX}"
                                setupData = setupData + "\nGERRIT_VOLUME_SNAPSHOT_ID:= ${params.GERRIT_VOLUME_SNAPSHOT_ID}"

                                writeFile(file:"setup.env", text: setupData)
                            }
                            sh 'echo "*** Computed values:"'
                            sh 'echo "* Subdomain: $SUBDOMAIN"'
                            sh 'echo "* Base URL: $BASE_URL"'
                            sh 'echo "* Gerrit HTTP URL: $GERRIT_HTTP_URL"'
                            sh 'echo "* Gerrit SSH URL: $GERRIT_SSH_URL"'
                            sh 'echo "Docker host: $DOCKER_HOST"'
                            sh "make AWS_REGION=${params.AWS_REGION} AWS_PREFIX=${params.AWS_PREFIX} GERRIT_VERSION=${params.GERRIT_VERSION} GERRIT_WAR_URL=${params.GERRIT_WAR_URL} GERRIT_PATCH=${params.GERRIT_PATCH} create-all"
                         }
                     }
                }
            }
            stage('Extract Gatling test user credentials from Gerrit') {
                steps {
                    retry(50) {
                        sleep(10)
                        sh "curl --fail -L -I '${env.GERRIT_HTTP_URL}/config/server/healthcheck~status' 2>/dev/null"
                        sh "curl -L -c cookies -i -X POST '${env.GERRIT_HTTP_URL}/login/%2Fq%2Fstatus%3Aopen%2B-is%3Awip?account_id=1000000'"
                    }
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
                    withCredentials([usernamePassword(usernameVariable: "DEFAULT_GIT_HTTP_USERNAME",
                            passwordVariable: "DEFAULT_GIT_HTTP_PASSWORD",
                            credentialsId: "gatlingHttp")]) {
                        script {

                            def gitHttpUsername = ("${params.GIT_HTTP_USERNAME}"?.trim()) ?: "${env.DEFAULT_GIT_HTTP_USERNAME}"
                            def gitHttpPassword = ("${params.GIT_HTTP_PASSWORD}"?.trim()) ?: "${env.DEFAULT_GIT_HTTP_PASSWORD}"

                            writeFile(file: "simulation.env", text: """
                                    GERRIT_HTTP_URL=${env.GERRIT_HTTP_URL}
                                    GERRIT_SSH_URL=${env.GERRIT_SSH_URL}
                                    ACCOUNT_COOKIE=${accountCookie}
                                    GIT_HTTP_USERNAME=${gitHttpUsername}
                                    GIT_HTTP_PASSWORD=${gitHttpPassword}
                                    XSRF_TOKEN=${xsrfToken}
                                    GERRIT_PROJECT=${params.GERRIT_PROJECT}
                                    NUM_USERS=${params.NUM_USERS}
                                    DURATION=${params.DURATION}
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
            stage("Export Cloudwatch logs to S3") {
                steps {
                    withCredentials([usernamePassword(usernameVariable: "AWS_ACCESS_KEY_ID",
                            passwordVariable: "AWS_SECRET_ACCESS_KEY",
                            credentialsId: "aws-credentials-id")]) {
                        dir ('aws-gerrit/single-primary') {
                            sh "make AWS_REGION=${params.AWS_REGION} AWS_PREFIX=${params.AWS_PREFIX} EXPORT_FROM_MILLIS=${epochTime} S3_EXPORT_LOGS_BUCKET_NAME=${params.S3_EXPORT_LOGS_BUCKET_NAME} export-logs"
                        }
                    }
                }
            }
            stage('Check tests results') {
                steps {
                    script {
                        def failed_tests = sh(
                                returnStdout: true,
                                script: "for i in `find ${WORKSPACE} -name \"global_stats.json\"`; do cat \$i | jq '.numberOfRequests.ko'| grep -v '0' || true;  done;"
                        )
                        if (failed_tests.trim()) {
                            error("Setting build as failed because some gatling tests were not OK")
                        }
                    }
                }
            }
        }
        post {
            cleanup {
                withCredentials([usernamePassword(usernameVariable: "AWS_ACCESS_KEY_ID", 
                    passwordVariable: "AWS_SECRET_ACCESS_KEY",
                    credentialsId: "aws-credentials-id")]) {
                        dir ('aws-gerrit/single-primary') {
                            sh "make AWS_REGION=${params.AWS_REGION} AWS_PREFIX=${params.AWS_PREFIX} delete-all"
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