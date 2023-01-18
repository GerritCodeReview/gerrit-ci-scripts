"""Docker image for Jenkins server"""

from pathlib import Path

import pulumi
import pulumi_docker as docker
from pulumi_docker import DockerBuild

stack = pulumi.get_stack()

JENKINS_SERVER_IMAGE_NAME = "jenkins-server"
# https://get.jenkins.io/war-stable/2.375.2
JENKINS_WAR_VER = "2.375.2-lts"
JENKINS_WAR_SHA = "e572525f7fa43b082e22896f72570297d88daec4f36ab4f25fdadca885f95492"
PLUGIN_FILE = "plugins.txt"
GF_JENKINS_SERVER_VERSION = "0.1"

cwd = Path(__file__).parent
build_dir = cwd / 'build'

backend = docker.Image(
    name="jenkins_server",
    build=DockerBuild(context=str(build_dir),
                      args={
                          "JENKINS_WAR_VER": JENKINS_WAR_VER,
                          "JENKINS_WAR_SHA": JENKINS_WAR_SHA,
                          "PLUGIN_FILE": PLUGIN_FILE
                      }),
    local_image_name="gerritforge/jenkins-server:" + GF_JENKINS_SERVER_VERSION,
    image_name="gerritforge/jenkins-server:" + GF_JENKINS_SERVER_VERSION,
    skip_push=True)

USE_SECURITY="false"
JENKINS_HOME="/tmp/jenkins_home"
OAUTH_ID="clientid"
OAUTH_SECRET="secret"
JENKINS_API_USER="user"
JENKINS_API_PASSWORD="pass"
IMAGE=f"gerritforge/{JENKINS_SERVER_IMAGE_NAME}:{GF_JENKINS_SERVER_VERSION}"
NAME="gerrit-ci"
DOCKER_GID=993

print(f"""
	docker run --name {NAME} -d -e USE_SECURITY={USE_SECURITY} \
          -e OAUTH_ID={OAUTH_ID} \
          -e OAUTH_SECRET={OAUTH_SECRET} \
          -e JENKINS_API_USER={JENKINS_API_USER} \
          -e JENKINS_API_PASSWORD={JENKINS_API_PASSWORD} \
          -e DOCKER_GID={DOCKER_GID} \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v {JENKINS_HOME}/jobs:/var/jenkins_home/jobs \
          -v {JENKINS_HOME}/.netrc:/var/jenkins_home/.netrc \
          -v {JENKINS_HOME}/.secrets:/var/jenkins_home/.secrets \
          --net=host {IMAGE}
""")