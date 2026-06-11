#
# First stage: 
# Building a frontend.
#

FROM alpine:3.17 AS frontend

# Move to a working directory (/static).
WORKDIR /static

# https://stackoverflow.com/questions/69692842/error-message-error0308010cdigital-envelope-routinesunsupported
ENV NODE_OPTIONS=--openssl-legacy-provider
# Install npm (with latest nodejs) and yarn (globally, in silent mode).
RUN apk add --no-cache nodejs npm && \
    npm i -g -s --unsafe-perm yarn

# Copy only ./ui folder to the working directory.
COPY ui .

# Run yarn scripts (install & build).
RUN yarn install && yarn build

#
# Second stage:
# Preparing runtime certificates.
#

FROM alpine:3.17 AS certs

RUN apk add --no-cache ca-certificates

#
# Third stage:
# Building a backend.
#

FROM golang:1.18-alpine AS backend

# Move to a working directory (/build).
WORKDIR /build

# Copy and download dependencies.
COPY go.mod go.sum ./
RUN go mod download

# Copy a source code to the container.
COPY . .

# Copy frontend static files from /static to the root folder of the backend container.
COPY --from=frontend ["/static/build", "ui/build"]

# Set the target platform for multi-arch Docker builds.
ARG TARGETOS
ARG TARGETARCH

# Run go build (with ldflags to reduce binary size).
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-s -w" -o asynqmon ./cmd/asynqmon

#
# Fourth stage:
# Creating and running a new scratch container with the backend binary.
#

FROM scratch

# Copy CA certificates for Redis TLS and HTTPS Prometheus endpoints.
COPY --from=certs ["/etc/ssl/certs/ca-certificates.crt", "/etc/ssl/certs/"]

# Copy binary from /build to the root folder of the scratch container.
COPY --from=backend ["/build/asynqmon", "/"]

EXPOSE 8080

USER 65532:65532

# Command to run when starting the container.
ENTRYPOINT ["/asynqmon"]
