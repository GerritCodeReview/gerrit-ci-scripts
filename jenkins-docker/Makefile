AGENT_DIRS ?= agent-debian agent-chrome agent-node-wct agent-bazel-nocache agent-bazel agent-bazel-docker agent-sbt agent-mvn agent-release agent-python3 agent-jekyll agent-aws
ALL_DIRS ?= server bazel-cache $(AGENT_DIRS)
NO_CACHE ?= true

default: build

build clean publish:
	for dir in $(ALL_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir $@) || exit 1; done

publish_agent:
	for dir in $(AGENT_DIRS); do (make NO_CACHE=$(NO_CACHE) -C $$dir build publish) || exit 1; done

start stop restart:
	make -C server $@

