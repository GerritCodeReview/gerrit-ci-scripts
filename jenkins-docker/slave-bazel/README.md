slave-bazel
============

To build this image, you have to have slave-buck and slave already built.

You can proceed if the images have been built.

1. edit the Dockerfile and replace gerritforge/gerrit-ci-slave-buck with slave-buck

2. docker build -t slave-bazel .

#### to run, do the following

3. docker run --security-opt seccomp:unconfined slave-bazel

4. you need to open a seperate console

5. docker ps

6. using the number from docker ps for slave-bazel do the following:
   docker exec -i -t <ps_num> bash -i

7. to stop a  container do the following
   docker container stop <ps_num>
