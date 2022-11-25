"""Docker image for Jenkins server"""

from pathlib import Path

import pulumi
import pulumi_docker as docker
from pulumi_docker import DockerBuild

stack = pulumi.get_stack()

JENKINS_SERVER_IMAGE_NAME = "jenkins-server"
JENKINS_VERSION = "2.222.4"
# https://get.jenkins.io/war-stable/2.346.3/
JENKINS_WAR_VER = "2.346.3-2-lts"
JENKINS_WAR_SHA = "141e8c5890a31a5cf37a970ce3e15273c1c74d8759e4a5873bb5511c50b47d89"
GF_JENKINS_SERVER_VERSION = "0.1"

cwd = Path(__file__).parent
build_dir = cwd / 'build'

# docker.build_and_push_image
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

NAME = "gerrit-ci"
USE_SECURITY = "false"
OAUTH_ID = "clientid"
OAUTH_SECRET = "secret"
JENKINS_API_USER = "user"
JENKINS_API_PASSWORD = "pass"
JENKINS_HOME = "~/jenkins_home"
DOCKER_GID = 993

# docker.Container(NAME,)
# mkdir -p ${JENKINS_HOME}/jobs
print(f"docker run --name {NAME} -d -e USE_SECURITY={USE_SECURITY} \
        -e OAUTH_ID={OAUTH_ID} \
        -e OAUTH_SECRET={OAUTH_SECRET} \
        -e JENKINS_API_USER={JENKINS_API_USER} \
        -e JENKINS_API_PASSWORD={JENKINS_API_PASSWORD} \
        -e DOCKER_GID={DOCKER_GID} \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v {JENKINS_HOME}/jobs:/var/jenkins_home/jobs \
        -v {JENKINS_HOME}/.netrc:/var/jenkins_home/.netrc \
        -v {JENKINS_HOME}/.secrets:/var/jenkins_home/.secrets \
        --net=host gerritforge/jenkins-server:{GF_JENKINS_SERVER_VERSION}")
