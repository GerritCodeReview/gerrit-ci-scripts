NO_CACHE=false
IMAGE=gerritforge/bazel-cache
CACHE_ALLOW=0.0.0.0/0

# Targets

build:
	docker build --no-cache=$(NO_CACHE) -t ${IMAGE} .

publish:
	docker push ${IMAGE}

clean:
	docker rmi -f ${IMAGE}

start:
	docker run --rm -d -e NGINX_WEBDAV_ALLOW=${CACHE_ALLOW} --net=host --name bazel_cache ${IMAGE}

stop:
	docker kill bazel_cache

.PHONY: clean image publish start stop
