DIRS=master slave-debian slave-buck slave-mvn slave-bazel slave-sbt

default: start

build clean publish:
	for dir in ${DIRS}; do make -C $$dir $@; done

build-bazel:
	make -C master id_rsa
	for dir in slave-debian slave-bazel; do make -C $$dir build; done

start stop restart:
	make -C master $@

