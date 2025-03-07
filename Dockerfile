#FROM --platform=$BUILDPLATFORM golang:1.24.1-alpine3.20 AS build
FROM golang:1.24-alpine3.20 AS build
WORKDIR /src

# download go modules
COPY go.mod .
COPY go.sum .
RUN go mod download
RUN go mod vendor

COPY . .

# RUN [ "$TARGETPLATFORM" = "linux/amd64"  ] && echo GOOS=linux GOARCH=amd64 > .env || true
# RUN [ "$TARGETPLATFORM" = "linux/arm64"  ] && echo GOOS=linux GOARCH=arm64 > .env || true
# RUN [ "$TARGETPLATFORM" = "linux/arm/v6" ] && echo GOOS=linux GOARCH=arm GOARM=6 > .env || true
# RUN [ "$TARGETPLATFORM" = "linux/arm/v7" ] && echo GOOS=linux GOARCH=arm GOARM=7 > .env || true

ENV CGO_ENABLED=0
#RUN go env -w GO111MODULE=auto
#RUN env $(cat .env | xargs) go build -o /docker-ipv6nat.$(echo "$TARGETPLATFORM" | sed -E 's/(^linux|\/)//g') ./cmd/docker-ipv6nat
RUN go build -o /docker-ipv6nat ./cmd/docker-ipv6nat

FROM alpine:3.20 AS release
RUN apk add --no-cache ip6tables
COPY --from=build /docker-ipv6nat.* /docker-ipv6nat
COPY docker-ipv6nat-compat /
ENTRYPOINT ["/docker-ipv6nat-compat"]
CMD ["--retry"]
