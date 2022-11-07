"""Docker image for Jenkins server"""

from pathlib import Path

import pulumi
import pulumi_docker as docker
from pulumi_docker import DockerBuild

stack = pulumi.get_stack()

JENKINS_SERVER_IMAGE_NAME = "jenkins-server"
JENKINS_VERSION = "2.222.4"
JENKINS_WAR_VER = "2.222.4"
# https://get.jenkins.io/war-stable/2.222.4/
JENKINS_WAR_SHA = "6c95721b90272949ed8802cab8a84d7429306f72b180c5babc33f5b073e1c47c"
GF_JENKINS_SERVER_VERSION = "0.1"

cwd = Path(__file__).parent
build_dir = cwd / 'build'

backend = docker.Image(
    name="jenkins_server",
    build=DockerBuild(context=str(build_dir),
                      args={
                          "JENKINS_WAR_VER": JENKINS_WAR_VER,
                          "JENKINS_WAR_SHA": JENKINS_WAR_SHA
                      }),
    local_image_name="gerritforge/jenkins-server:" + GF_JENKINS_SERVER_VERSION,
    image_name="gerritforge/jenkins-server:" + GF_JENKINS_SERVER_VERSION,
    skip_push=True)
