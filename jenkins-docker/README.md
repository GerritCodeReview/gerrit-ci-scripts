# Gerrit CI Docker Image

This is a Docker image based on the Jenkins Docker image that allows users
to build and test the Gerrit CI jobs automatically, based on the configuration
at https://github.com/GerritCodeReview/gerrit-ci-scripts/

In turn, these CI scripts are based on
http://docs.openstack.org/infra/jenkins-job-builder/ -- which builds Jenkins
jobs based on YAML configurations.

In this particular image, the YAML configurations are updated and jobs
reloaded every 5 minutes via the Jenkins SCM trigger.  These jobs are fetched
from the gerrit-ci-scripts repository and automatically reloaded.

It is also possible to run the gerrit-ci-scripts-manual job and provide the
legacy Change ID number and a particular revision to build: Jenkins will fetch
this particular change and load any job configurations changed in this revision.
Note that it will not inhibit the main gerrit-ci-scripts trigger from polling.

## Notes for users of boot2docker

If you're using boot2docker, the stock drive image and memory will not be enough.
I would recommend growing your boot2docker volume to at least 40GB, and perhaps
adding an extra 2-4GB swap space at the end of the volume.  Additionally, you
may wish to increase the amount of memory allocated to your boot2docker VM to
at least 3GB (4GB+ preferred).  Failing to do this may result in unusual
failures of the VM or build errors.

For more information on enlarging the boot2docker volume, please see:
https://docs.docker.com/articles/b2d_volume_resize/

## Building all the images with one command

make build

## Images

Images available are:

* gerritforge/gerrit-ci-agent: Base Jenkins agent with OS and prerequisites.

* gerritforge/gerrit-ci-agent-debian: Base Jenkins agent with OS and prerequisites.

* gerritforge/gerrit-ci-agent-bazel: Bazel build for gerrit 2.14+.

* gerritforge/gerrit-ci-agent-bazel-sbt: Setups scala for plugins that use scala.

* gerritforge/gerrit-ci-agent-mvn - Setups maven for plugins that use maven.

## Running the container

* docker run --privileged -it <image_name> bash

If your not familar with docker please follow https://docs.docker.com/get-started/

## Running Gerrit-CI locally

The Gerrit-CI server runs as a Docker Compose stack: Jenkins, haproxy in front
of it, and nginx serving the theme and the plugin manager. All commands below
are run from the `server` directory.

On Linux, `make start` builds the image and starts the stack:

    make start

On macOS, use `make start_osx` instead. It does not build the image, so build
it first:

    make build
    make start_osx

`start_osx` also starts a `gerrit-ci-socat` container that exposes the host
Docker socket on `127.0.0.1:1234`.

### arm64 hosts (Apple Silicon)

`requirements.txt` pins the hashes of the x86_64 Python wheels only, so a
native arm64 build fails at the `pip install` step. Build the image for
linux/amd64 instead; Docker Desktop provides the emulation this needs:

    DOCKER_DEFAULT_PLATFORM=linux/amd64 make build
    make start_osx

Set `DOCKER_DEFAULT_PLATFORM` for the build only, so that haproxy and nginx
keep running natively.

### Accessing Jenkins

Jenkins is served by haproxy at https://localhost/; plain HTTP on port 80
redirects to HTTPS. On the first start a self-signed certificate is generated
in `server/tls/gerrit-ci.pem`, so expect a browser warning.

The Jenkins URL is set to https://gerrit-ci.gerritforge.com/ in
`jenkins.model.JenkinsLocationConfiguration.xml`, so absolute links generated
by Jenkins point to production.

Follow the logs with `make log` (`make log_osx` on macOS) and stop the stack
with `make stop`. `make clean` removes the image and `JENKINS_HOME`.

### Configuration

The `Makefile` variables can be overridden on the command line, for example
`make start_osx JENKINS_HOME=/tmp/gerrit-ci`:

| Variable | Default | Purpose |
|----------|---------|---------|
| `JENKINS_HOME` | `~/jenkins_home` | Host directory holding `jobs`, `.netrc` and `.secrets`, mounted into Jenkins. The rest of the Jenkins configuration lives in the container. |
| `USE_SECURITY` | `false` | With `false`, Jenkins security is disabled and haproxy lets every request through. |
| `OAUTH_ID`, `OAUTH_SECRET` | `clientid`, `secret` | GitHub OAuth app used to log in when `USE_SECURITY=true`. |

To log in with GitHub, create a GitHub OAuth app with the callback URL
`https://localhost/securityRealm/finishLogin` and start the stack with:

    make start_osx USE_SECURITY=true OAUTH_ID=<client-id> OAUTH_SECRET=<client-secret>

At startup Jenkins loads its credentials from `$JENKINS_HOME/.netrc` and
`$JENKINS_HOME/.secrets` (JSON, format described in `setCredentials.groovy`).
If they don't exist, Docker creates them as empty directories and Jenkins
starts without any credentials.
