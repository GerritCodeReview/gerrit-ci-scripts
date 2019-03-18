# Gerrit CI Docker Image

This is a Docker image based on the Jenkins Docker image that allows users
to build and test the Gerrit CI jobs automatically, based on the configuration
at https://gerrit.googlesource.com/gerrit-ci-scripts/

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

## Starting Jenkins

To start Jenkins and the reverse proxy regulating ingress traffic, follow the
following steps:

### (Optional) Provide SSL certificates to enable HTTPS

The reverse proxy will serve traffic via HTTPS. To do this it requires a
certificate and key. For browsers to trust these certificates, certificates
from trusted authorities (e.g. digicert) can be used. To do this, put both the
certificate and the key into the same folder and name them `cert.crt` and
`cert.key` respectively.

If no certificates are provided, the Nginx-container will create self-signed
certificates.

### (Optional) Provide a CA-certificate for authentication

For authentication of users a CA-certificate will be needed, since certificate-
based authentication will be used. Put the CA-certificate into the same directory
as the SSL certificates and call it `auth_ca.crt`.

To allow a user to access Jenkins get a certificate for this user with this CA.
The username should be set in the CN-field of the CSR's-subject. The username then
also has to be set in the `config.xml`of Jenkins to configure permissions.

If no CA will be provided, certificate-based authentication will be disabled. All
users will be anonymous.

### Start up Nginx and Jenkins

In the directory of this README run:

```sh
make \
  USE_SECURITY=true \
  JENKINS_API_USER=user \
  JENKINS_API_PASSWORD=pass \
  JENKINS_HOME=~/jenkins_home \
  NGINX_CERTS=~/.ssl \
  start
```

If no CA for authentication was provide use `USE_SECURITY=false`, otherwise only
read-access will be available. The `NGINX_CERTS`-variable should point to the
directory containing the SSL-certificates and authentication-CA.

## Slave images

Images available are:

* gerritforge/gerrit-ci-slave: Base Jenkins slave with OS and prerequisites.

* gerritforge/gerrit-ci-slave-debian: Base Jenkins slave with OS and prerequisites.

* gerritforge/gerrit-ci-slave-bazel: Bazel build for gerrit 2.14+.

* gerritforge/gerrit-ci-slave-bazel-sbt: Setups scala for plugins that use scala.

* gerritforge/gerrit-ci-slave-mvn - Setups maven for plugins that use maven.

## Running the container

* docker run --privileged -it <image_name> bash

If your not familar with docker please follow https://docs.docker.com/get-started/

## Contributing slave to Gerrit Code Review verification

* Set up root server with running docker service.
* Generate ecdsa SSH key and send public key to CI maintainer:

----
  $ ssh-keygen -t ecdsa -b 521
----

* Ask CI maintainer to generate for you unique slave id.

* Run `cat /proc/cpuinfo` and report CI maintainer the number of CPUs, so
that your slave would not get overloaded.

* Clone gerrit-ci-scripts repository:

----
  $ git clone https://gerrit.googlesource.com/gerrit-ci-scripts
----

* Make sure `ppp` package is installed, e.g. on Ubuntu run:

----
  $ apt-get install ppp
----

* Activate Docker's remote API. On Ubuntu, add this option to systemd script:

----
  $ cat /lib/systemd/system/docker.service
  [...]
  ExecStart=/usr/bin/dockerd -H tcp://10.0.9.1:2375 -H fd://
----

Caution: Don't expose generic interface: `-H tcp://0.0.0.0:2375`,
otherwise, your Docker container could be hijacked.

* Reload systemd and restart docker service:

----
  $ systemctl daemon-reload
  $ systemctl restart docker.service
----

* Add this line to crontab job (replace <your_slave_id>):

----
*/5 * * * * /root/gerrit-ci-scripts/worker/tunnel.sh <your_slave_id>
----

* In case your server is behind a Firewall, open tcp/2375 port for
incoming requests.

* Check on https://gerrit-ci.gerritforge.com and running `docker ps`
that your slave is up and running and build jobs are scheduled. If all
went well and when jobs have arrived you should see something like:

----
  $ docker ps
  CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS
  d9ff4b6a8b1c        gerritforge/jenkins-slave-bazel:debian   "bash -x /bin/star..."   6 minutes ago       Up 6 minutes        0.0.0.0:32792->22/tcp
----
