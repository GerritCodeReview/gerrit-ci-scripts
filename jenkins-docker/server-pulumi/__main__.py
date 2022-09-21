"""Docker image for Jenkins server"""

import pulumi
import pulumi_docker as docker

stack = pulumi.get_stack()

jenkins_version = "2.222.4"

jenkins_server_image_name = "jenkins-server"
backend = docker.RemoteImage(jenkins_server_image_name,
                             name="jenkins/jenkins:" + jenkins_version)
