FROM golang:1.21-alpine AS builder

WORKDIR /app

RUN go mod download

COPY scripts/* ./

# Generate go.sum and build the application
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o pod-watcher .

FROM amazon/aws-cli:2.17.23

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/pod-watcher .

# Set entrypoint 
ENTRYPOINT ["./pod-watcher"]