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

## Running the images

To run the images please do the following

* docker images

* docker run --security-opt seccomp:unconfined <image>

* you need to open a seperate console

* docker ps

* using the number from docker ps for <image> do the following:
   docker exec -i -t <ps_num> bash -i

* to exit a container type the following, exit.

   If for some reason the container did not stop, you can do
   docker container stop <ps_num>

Note: If you want to delete images, please follow
https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes
