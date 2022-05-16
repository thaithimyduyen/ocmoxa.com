IMAGE?=ocmoxa-com

build:
	docker build . -t ${IMAGE}
.PHONY: build

run:
	docker run -it --rm -p 8081:80 ${IMAGE}
.PHONY: run
