# Use the offical Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.14.4-alpine as builder

# Copy local code to the container image.
WORKDIR /app
COPY . .
RUN ls -la /app

## Build the command inside the container.
RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -o go-hello-world
#
# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine
RUN apk add --no-cache ca-certificates

# Copy timezone
COPY --from=builder /usr/local/go/lib/time/zoneinfo.zip /
#ENV TZ=Asia/Bangkok
ENV ZONEINFO=/zoneinfo.zip

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/configs  /configs
COPY --from=builder /app/go-hello-world /go-hello-world

# Run the web service on container startup.
CMD ["/go-hello-world"]