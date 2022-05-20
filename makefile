IMAGE?=ocmoxa-com
NAMESPACE?=ocmoxa-prod

build:
	DOCKER_BUILDKIT=1 docker build --progress=plain --platform=linux/amd64 . -t ${IMAGE}
.PHONY: build

run:
	docker run -it --rm -p 8081:80 ${IMAGE}
.PHONY: run

deploy:
	kubectl delete all -n ${NAMESPACE} -l app=ocmoxa-web
	kubectl create -n ${NAMESPACE} -f k8s.yaml
.PHONY: deploy

prepare:
	kubectl create namespace ${NAMESPACE}
	kubectl create secret \
    	docker-registry regcred \
		--docker-server=registry.gitlab.com \
		--docker-username=gitlab+deploy-token-1050302 \
		--docker-password=q9rrMJqN8HLbq-EVkzJM \
		--docker-email=thai.duyen@ocmoxa.com \
		-n ${NAMESPACE}
	$(MAKE) deploy
.PHONY: prepare

cleanup:
	kubectl delete namespace ${NAMESPACE}
.PHONY: cleanup
