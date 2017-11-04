NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave
VERSION=ubuntu15.04-chrome60

build:  id_rsa.pub
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE}:${VERSION} .

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

publish:
	docker push ${IMAGE}:${VERSION}

clean:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub publish

