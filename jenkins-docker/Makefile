SLAVE_DIRS ?= slave-debian slave-chrome slave-buck slave-mvn slave-bazel slave-sbt
ALL_DIRS ?= master $(SLAVE_DIRS)

default: build

build clean publish:
	for dir in $(ALL_DIRS); do make -C $$dir $@; done

build_slave:
	for dir in $(SLAVE_DIRS); do make -C $$dir build; done

start stop restart:
	make -C master $@

