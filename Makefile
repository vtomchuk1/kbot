.ONESHELL:

APP?=kbot
# APP?=$(shell basename $(shell git remote get-url origin))
# REGESTRY?=keks8953
REGESTRY?=ghcr.io/vtomchuk1
VERSION?=v1.1.0-$(shell git rev-parse --short HEAD)
TARGETOS?=$(shell uname -s | tr '[:upper:]' '[:lower:]')
TARGETARCH?=$(shell dpkg --print-architecture)
IMAGE_NAME?=${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}
# CONTAINER_ID=$(shell docker ps -a -q --filter "ancestor=$(IMAGE_NAME)")

prometheus:
	kubectl port-forward svc/kube-prometheus-kube-prome-prometheus 9090:9090 -n monitoring

grafana:
	kubectl port-forward svc/kube-prometheus-grafana 3200:80 -n monitoring

argo:
	kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""
	kubectl port-forward service/my-argo-cd-argocd-server -n default 8080:443

jenkins:
	kubectl exec --namespace default -it svc/my-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
	@echo ""
	kubectl --namespace default port-forward svc/my-jenkins 8080:8080

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

info:
	$(info APP=$(APP))
	$(info REGESTRY=$(REGESTRY))
	$(info VERSION=$(VERSION))
	$(info TARGETOS=$(TARGETOS))
	$(info TARGETARCH=$(TARGETARCH))
	$(info IMAGE_NAME=$(IMAGE_NAME))
# 	$(info CONTAINER_ID=$(CONTAINER_ID))

clean:
	- rm -rf kbot || echo "Файл не знайдено, пропускаю"
# 	- docker rm ${CONTAINER_ID} || echo "Контейнер не знайдено, пропускаю"
	- docker rmi ${IMAGE_NAME} || echo "Образ не знайдено, пропускаю"
	- rm -rf helm-0.1.0.tgz || echo "Файл не знайдено, пропускаю"

get:
	go get

build: 
	$(MAKE) get
	$(MAKE) format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="test_docker/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${IMAGE_NAME}
	
push:
	docker push ${IMAGE_NAME}

linux:
	$(MAKE) TARGETOS=linux

arm64:
	$(MAKE) TARGETARCH=arm64

amd64:
	$(MAKE) TARGETARCH=amd64

windows:
	$(MAKE) TARGETOS=windows

darwin:
	$(MAKE) TARGETOS=darwin

helm-check:
	helm lint ./helm

helm-package:
	helm package ./helm

helm-install:
	helm install kbot ./helm

helm-uninstall:
	helm uninstall kbot

helm-upload:
	gh release upload v1.0.9 helm-0.1.0.tgz

helm-generate-secret:
	kubectl create secret generic kbot \
  --from-literal=token="TELE_TOKEN" \
  --namespace=kbot \
  --dry-run=client -o yaml | \
    $(go env GOPATH)/bin/kubeseal \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system \
  --format yaml > templates/sealedsecret.yaml