class Config {
  static boolean no_cache = true;
  static Set<String> images = [
    'master',
    'slave-debian',
    'slave-chrome',
    'slave-node-wct',
    'slave-buck',
    'slave-bazel',
    'slave-mvn',
    'slave-sbt'
  ];
  static Set<String> jobsToRunForTesting = [
    'gerrit-bazel-master',
    'gerrit-bazel-stable-2.16',
    'gerrit-buck-stable-2.13'
  ];
}

// The test node needs curl, docker and java

node ('jenkins-test'){ //TODO: change name to final node label
  gerritReview labels: [Verified: 0]
  checkout scm
  stage('Preparing project for testing'){
    //Remove PollSCM-trigger from gerrit-ci-scripts job to avoid creating and starting all jobs at once
    sh(scripts: "sed -i '/<trigger>/,/<\/trigger>/d' jenkins-docker/master/gerrit-ci-scripts.xml")
  }

  try {
    Config.images.each {
      stage("Building ${it}"){
        sh(script: '''
          export NO_CACHE=${Config.no_cache}
          cd jenkins-docker/${it}
          make build
          ''')
      }
    }

    stage('Start Jenkins test instance'){
      sh(script: '''
        cd jenkins-docker/master
        make start
        ''')
      sh(script: '''
        while [[ $(curl -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do
          sleep 5
        done
        ''')
      sh(script: '''
        curl -LO http://localhost:8080/jnlpJars/jenkins-cli.jar
      ''')
    }

    stage("Create jobs"){
      Config.jobsToRunForTesting.each {
        sh(script: "java -jar jenkins-cli.jar -s http://localhost:8080 build gerrit-ci-scripts-manual -f -v -p CHANGE_NUMBER=${CHANGE_NUMBER} -p JOBS=${it}")
      }
    }

    Config.jobsToRunForTesting.each {
      stage("Testing job ${it}"){
        sh(script: "java -jar jenkins-cli.jar -s http://localhost:8080 build ${it} -f -v")
      }
    }

    gerritReview labels: [Verified: 1]
  } catch (e) {
    gerritReview labels: [Verified: -1]
    throw e
  }
}