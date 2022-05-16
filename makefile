build:
	docker build . -t ocmoxa-com
.PHONY: build

run:
	docker run -it --rm -p 8081:80  ocmoxa-com
.PHONY: run
