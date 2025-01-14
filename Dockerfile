FROM golang:1.19-buster as builder

WORKDIR /app

COPY go.* ./
RUN go mod download
RUN go mod tidy

COPY . ./

RUN go build -mod=readonly -v -o server

FROM golang:1.18-buster AS build
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/server /app/server

CMD ["/app/server"]









-------------------------


updated one 






# Use the official Golang image to create a binary.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.19-buster AS builder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy local code to the container image.
COPY . .

# Build the binary.
RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o server .

# Use the official Debian slim image for a lean production container.
# https://hub.docker.com/_/debian
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM debian:buster-slim

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/server /app/server

# Expose port
EXPOSE 8000

# Run the web service on container startup.
CMD ["/app/server"]