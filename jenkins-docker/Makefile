SLAVE_DIRS ?= slave-debian slave-chrome slave-node-wct slave-bazel-nocache slave-bazel slave-bazel-docker slave-sbt slave-mvn slave-release slave-python3 slave-jekyll slave-aws
ALL_DIRS ?= master bazel-cache $(SLAVE_DIRS)
NO_CACHE ?= true

default: build

build clean publish:
	for dir in $(ALL_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir $@) || exit 1; done

publish_slave:
	for dir in $(SLAVE_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir build publish) || exit 1; done

start stop restart:
	make -C master $@

