IMAGE?=ocmoxa-com

build:
	DOCKER_BUILDKIT=1 docker build --progress=plain --platform=linux/amd64 . -t ${IMAGE}
.PHONY: build

run:
	docker run -it --rm -p 8081:80 ${IMAGE}
.PHONY: run
