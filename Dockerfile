FROM golang:1.20-alpine3.18 AS builder
COPY go.mod go.sum *.go /src/
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux go build -o internship-2023

FROM alpine:3.18
# RUN apk --no-cache add ca-certificates
COPY --from=builder /src/internship-2023 /app/
# uncomment the following lines if you want to ssh into the container
# RUN mkdir /.ssh && chmod 700 /.ssh
# RUN chown -R nobody:nobody /.ssh
USER nobody:nobody
WORKDIR /app
EXPOSE 9090
CMD ["./internship-2023"]
