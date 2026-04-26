# FROM quay.io/projectquay/golang:1.26 as builder
FROM golang:1.26 as builder

RUN apt-get update && apt-get install -y make build-essential
# RUN apk add --no-cache make build-base

WORKDIR /go/src/app
COPY . .

# RUN go get винесено в Makefile
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# ENTRYPOINT ["./kbot"]
CMD ["go", "test", "-v", "./..."]