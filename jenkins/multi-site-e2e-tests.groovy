def accountCookie = ''
def xsrfToken = ''

pipeline {
        agent { label 'bazel-debian' }
        environment {
          JAVA_HOME = "/usr/lib/jvm/java-11-openjdk-amd64"
          DOCKER_HOST = """${sh(
              returnStdout: true,
              script: '/sbin/ip route|awk \'/default/ {print "tcp://"\$3":2375"}\''
          )}"""
          PATH = "${WORKSPACE}:$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH"
        }

        parameters {
            string(name: 'GERRIT_VERSION', defaultValue:"3.1", description: 'The gerrit version under test')
        }

        stages{
            stage("Setup multi-site") {
                steps {
                    withCredentials([usernamePassword(usernameVariable: "GS_GIT_USER", passwordVariable: "GS_GIT_PASS", credentialsId: "gerrit.googlesource.com")]) {
                        sh "curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o ${WORKSPACE}/docker-compose"
                        sh "chmod +x ${WORKSPACE}/docker-compose"
                        sh "docker-compose --version"
                        sh 'echo "machine gerrit.googlesource.com login $GS_GIT_USER password $GS_GIT_PASS">> ~/.netrc'
                        sh 'chmod 600 ~/.netrc'
                        sh 'rm -rf multi-site'
                        sh "git clone -b master https://gerrit.googlesource.com/plugins/multi-site"
                        sh "curl -o ${WORKSPACE}/release.war https://gerrit-ci.gerritforge.com/view/Gerrit/job/Gerrit-bazel-stable-${GERRIT_VERSION}/lastSuccessfulBuild/artifact/gerrit/bazel-bin/release.war"
                        sh "java -jar ${WORKSPACE}/release.war --version"
                        sh "curl -o ${WORKSPACE}/multi-site.jar https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.4/job/plugin-multi-site-bazel-${GERRIT_VERSION}/lastSuccessfulBuild/artifact/bazel-bin/plugins/multi-site/multi-site.jar"
                        dir("multi-site") {
                          sh "git config user.name jenkins && git config user.email jenkins@gerritforge.com"
                          // XXX: Just for testing
                          sh "git pull https://gerrit.googlesource.com/plugins/multi-site refs/changes/63/304963/8"
                          sh "mkdir -p ${WORKSPACE}/deployment"
                          sh "ls -lrt ${WORKSPACE}"
                          sh "./setup_local_env/setup.sh --deployment-location ${WORKSPACE}/deployment --replication-type file --release-war-file ${WORKSPACE}/release.war --multisite-lib-file ${WORKSPACE}/multi-site.jar --ci-setup true"
                        }
                     }
                }
            }
      }
}
