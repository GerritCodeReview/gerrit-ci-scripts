pipeline {
		agent { label 'sbt' }
		parameters {
        	string(name: 'GERRIT_HTTP_URL', defaultValue: 'https://gerrit-master-demo.gerrit-demo.gerritforgeaws.com')
        	string(name: 'GERRIT_SSH_URL', defaultValue: 'ssh://gerritadmin@gerrit-master-demo.gerrit-demo.gerritforgeaws.com:29418')
        	string(name: 'GIT_HTTP_USERNAME', defaultValue: 'gerritadmin')
        	string(name: 'GIT_HTTP_PASSWORD')
        	string(name: 'GERRIT_PROJECT', defaultValue: 'load-test')
        	string(name: 'ACCOUNT_COOKIE')
        	string(name: 'XSRF_TOKEN')
        	
    	}
		stages{
			stage('Checkout Gatling tests project') {
				steps {
	                    sh 'rm -rf gatling-sbt-gerrit-test'
	                    sh "git clone -b master https://github.com/GerritForge/gatling-sbt-gerrit-test.git"
	                    sh "cd gatling-sbt-gerrit-test && git fetch origin master && git config user.name jenkins && git config user.email jenkins@gerritforge.com && git merge FETCH_HEAD"
				}


			}

			stage('Run Gatling tests') {
				environment {
				    	GERRIT_HTTP_URL="${GERRIT_HTTP_URL}"
						GERRIT_SSH_URL="${GERRIT_SSH_URL}"
		 				ACCOUNT_COOKIE="${ACCOUNT_COOKIE}"
		 				GIT_HTTP_USERNAME="${GIT_HTTP_USERNAME}"
		 				GIT_HTTP_PASSWORD="${GIT_HTTP_PASSWORD}"
		 				XSRF_TOKEN="${XSRF_TOKEN}"
		 				GERRIT_PROJECT="${GERRIT_PROJECT}"
		 				GIT_SSH_PRIVATE_KEY_PATH = credentials('agerrit-ssh-key')
		 				GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    			}
				steps {
					dir ('gatling-sbt-gerrit-test') {
						sh "sbt gatling:test"
					}
					gatlingArchive()
				}
			}
		}
		
}