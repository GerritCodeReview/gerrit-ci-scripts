# Gerrit CI Docker Image

This is a Docker image based on the Jenkins Docker image that allows users
to build and test the Gerrit CI jobs automatically, based on the configuration
at https://gerrit.googlesource.com/gerrit-ci-scripts/

In turn, these CI scripts are based on 
http://docs.openstack.org/infra/jenkins-job-builder/ -- which builds Jenkins
jobs based on YAML configurations.

In this particular image, the YAML configurations are updated and jobs
reloaded every 5 minutes.  These jobs are fetched from the gerrit-ci-scripts
repository into /var/jenkins_home/gerrit-ci-scripts -- the fetch can be
suspended by touching the file TESTING in this directory.  The jobs will still
be reloaded every five minutes, but the update from the repository will not
occur.

## Notes for users of boot2docker

If you're using boot2docker, the stock drive image and memory will not be enough.
I would recommend growing your boot2docker volume to at least 40GB, and perhaps
adding an extra 2-4GB swap space at the end of the volume.  Additionally, you
may wish to increase the amount of memory allocated to your boot2docker VM to
at least 3GB (4GB+ preferred).  Failing to do this may result in unusual
failures of the VM or build errors.

For more information on enlarging the boot2docker volume, please see:
https://docs.docker.com/articles/b2d_volume_resize/
