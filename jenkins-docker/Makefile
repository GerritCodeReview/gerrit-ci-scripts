DIRS=master slave slave-buck

default: start

build clean:
	for dir in ${DIRS}; do make -C $$dir $@; done

start stop restart:
	make -C master $@

