APP=$(shell basename $(shell git remote get-url origin))
REGESTRY=keks8953
VERSION=v1-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=$(shell dpkg --print-architecture)

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

clean:
	rm -rf kbot

get:
	go get

build: 
	$(MAKE) get
	$(MAKE) format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="test_docker/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}