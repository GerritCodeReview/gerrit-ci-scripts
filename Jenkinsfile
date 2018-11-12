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
  ]
}


node ('master'){
  checkout scm
  try {
    Config.images.each {
      stage("Building ${it}"){
        sh(script:
          "export NO_CACHE=${Config.no_cache} && \
          cd jenkins-docker/${it} && \
          make build"
          )
      }
    }
  } catch (e) {
    throw e
  }
}