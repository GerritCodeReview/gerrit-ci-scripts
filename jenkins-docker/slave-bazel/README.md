slave-bazel
============

To build this image, you have to have slave-buck and slave already built.

You can proceed if the images have been built.

1. make build

#### to run, do the following

2. docker run --security-opt seccomp:unconfined gerritforge/gerrit-ci-slave-bazel

3. you need to open a seperate console

4. docker ps

5. using the number from docker ps for gerritforge/gerrit-ci-slave-bazel do the following:
   docker exec -i -t <ps_num> bash -i

6. to stop a  container do the following
   docker container stop <ps_num>

Note: If you want to delete images, please follow
https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes
