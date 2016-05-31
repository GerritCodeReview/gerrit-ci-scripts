DIRS=master slave

default: start

build clean:
	for dir in ${DIRS}; do make -C $$dir $@; done

start stop restart:
	make -C master $@

