APP?=$(shell basename $(shell git remote get-url origin))
REGESTRY?=keks8953
VERSION?=v1-$(shell git rev-parse --short HEAD)
TARGETOS?=$(shell uname -s | tr '[:upper:]' '[:lower:]')
TARGETARCH?=$(shell dpkg --print-architecture)
IMAGE_NAME?=${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}
# CONTAINER_ID=$(shell docker ps -a -q --filter "ancestor=$(IMAGE_NAME)")

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
	$(MAKE) TARGETOS=linux build

arm:
	$(MAKE) TARGETARCH=arm64 build

windows:
	$(MAKE) TARGETOS=windows build

macos:
	$(MAKE) TARGETOS=darwin build

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
	(go env GOPATH)/bin/kubeseal \
  --controller-name=sealed-secrets-operator \
  --controller-namespace=sealed-secrets \
  --format yaml > templates/sealedsecret.yaml