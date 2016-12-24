NO_CACHE=false
IMAGE=gerritforge/gerrit-ci-slave

build:  id_rsa.pub
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

id_rsa.pub: ../master/id_rsa.pub
	cp $? $@

clean:
	docker rmi -f ${IMAGE}
	-rm -f id_rsa*

.PHONY: clean id_rsa.pub

