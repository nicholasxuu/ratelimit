FROM golang:1.14 AS build
WORKDIR /ratelimit

RUN go env -w GOPROXY=https://goproxy.cn,direct

COPY go.mod go.sum /ratelimit/
RUN go mod download

COPY src src
COPY script script
COPY proto proto

RUN CGO_ENABLED=0 GOOS=linux go build -o /go/bin/ratelimit -ldflags="-w -s" -v github.com/envoyproxy/ratelimit/src/service_cmd

FROM alpine:3.11 AS final
RUN apk --no-cache add ca-certificates
RUN apk --no-cache add bash
COPY --from=build /go/bin/ratelimit /bin/ratelimit
