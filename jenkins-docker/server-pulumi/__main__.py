"""Docker image for Jenkins server"""

import fileinput
from pathlib import Path

import pulumi
import pulumi_docker as docker
from pulumi_docker import DockerBuild

stack = pulumi.get_stack()

JENKINS_SERVER_IMAGE_NAME = "jenkins-server"
JENKINS_VERSION = "2.222.4"
JENKINS_WAR_SHA = "924d2c9fabfdcacee1bae757337a07d7599eaa35"
JENKINS_WAR_VER = "2.204.1"
GF_JENKINS_SERVER_VERSION = "0.1"

cwd = Path(__file__).parent

def _prepare_dockerfile():
    with open(cwd / 'Dockerfile.template', 'r') as file:
        filedata = file.read()

    filedata = filedata.replace('_JENKINS_WAR_VER_', JENKINS_WAR_VER)
    filedata = filedata.replace('_JENKINS_WAR_SHA_', JENKINS_WAR_SHA)

    with open(cwd / 'Dockerfile', 'w') as file:
        file.write(filedata)


_prepare_dockerfile()

backend = docker.Image(
    name="jenkins_server",
    build=DockerBuild(),
    local_image_name="gerritforge/jenkins-server:" + GF_JENKINS_SERVER_VERSION,
    image_name="gerritforge/jenkins-server:" + GF_JENKINS_SERVER_VERSION,
    skip_push=True)