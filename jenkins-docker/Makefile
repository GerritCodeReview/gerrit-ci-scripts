DIRS ?= master slave-debian slave-chrome slave-node-wct slave-buck slave-mvn slave-bazel slave-sbt

default: start

build clean publish:
	for dir in $(DIRS); do make -C $$dir $@; done

start stop restart:
	make -C master $@

