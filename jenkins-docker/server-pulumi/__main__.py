"""Docker image for Jenkins server"""

import pulumi
import pulumi_docker as docker

stack = pulumi.get_stack()

JENKINS_SERVER_IMAGE_NAME = "jenkins-server"
JENKINS_VERSION = "2.222.4"
JENKINS_WAR_SHA = "924d2c9fabfdcacee1bae757337a07d7599eaa35"
JENKINS_WAR_VER = "2.204.1"

docker_template = """"
FROM jenkins/jenkins:${JENKINS_WAR_VER}

USER root

RUN echo "$JENKINS_WAR_SHA  /usr/share/jenkins/jenkins.war" | sha1sum -c -
"""


docker_file = pulumi.FileAsset("./Dockerfile")
docker_file.

print(docker_template)

# backend = docker.RemoteImage(JENKINS_SERVER_IMAGE_NAME,
#                              name="jenkins/jenkins:" + JENKINS_VERSION)
