NO_CACHE ?= false
IMAGE=gerritforge/gerrit-ci-slave-jekyll

build:  Dockerfile Makefile
	docker build --no-cache=$(NO_CACHE) -f Dockerfile -t $(IMAGE) .

publish: build
	docker push $(IMAGE)

clean:
	docker rmi -f $(IMAGE)
	-rm -f id_rsa*

.PHONY: clean
