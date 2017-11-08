slave-bazel
============

To build this image, you have to have slave-buck and slave already built.

You can proceed if the images have been built.

1. docker build -t slave-bazel .

#### to run, do the following

2. docker run --security-opt seccomp:unconfined slave-bazel

3. you need to open a seperate console

4. docker ps

5. using the number from docker ps for slave-bazel do the following:
   docker exec -i -t <ps_num> bash -i

6. to stop a  container do the following
   docker container stop <ps_num>
