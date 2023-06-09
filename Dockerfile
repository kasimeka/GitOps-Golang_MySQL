FROM golang:alpine3.18
COPY go.mod go.sum *.go /src/
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux go build -o internship-2023

FROM alpine:3.18
# RUN apk --no-cache add ca-certificates
COPY --from=0 /src/internship-2023 /app/
WORKDIR /app
CMD ["./internship-2023"]
