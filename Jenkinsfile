node {
  checkout scm

  gerritReview labels: [Verified: 0]
  stage('YAML lint') {
    sh 'pip3 install yamllint'
    def lintOut = sh (script: 'yamllint -c yamllint-config.yaml jenkins/**/*.yaml', returnStdout: true)
    def lintOutTrimmed = lintOut.trim()
    if (lintOutTrimmed) {
      def files = formatOut.split('\n').collect { it.split(' ').last() }
      gerritReview (labels: [Code-Style: -1], message: lintOutTrimmed)
    } else {
      gerritReview (labels: [Code-Style: 1])
    }
  }
}
