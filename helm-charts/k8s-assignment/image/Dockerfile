# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY scripts/go.mod ./

# Download dependencies
RUN go mod download

# Copy source code
COPY scripts/main.go ./

# Generate go.sum and build the application
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o pod-watcher .

# Final stage
FROM amazon/aws-cli:2.17.23

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/pod-watcher .

# Set entrypoint to our binary and remove AWS CLI default behavior
ENTRYPOINT ["./pod-watcher"]