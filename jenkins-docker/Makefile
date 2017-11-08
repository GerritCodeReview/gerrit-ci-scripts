DIRS=master slave slave-debian slave-buck slave-mvn slave-bazel slave-bazel-debian slave-sbt

default: start

build clean publish:
	for dir in ${DIRS}; do make -C $$dir $@; done

start stop restart:
	make -C master $@

