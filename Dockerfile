FROM --platform=${BUILDPLATFORM} golang:1.24-alpine3.21 AS builder
ARG TARGETARCH

WORKDIR /src
COPY src/go.mod src/go.sum ./
RUN go mod download

COPY src .
# statically linked cross-compiled binary, simplifies multiplatform image creation
RUN CGO_ENABLED=0 GOARCH=${TARGETARCH} go build -ldflags "-s -w" -o internship-2023 


FROM scratch

WORKDIR /app
COPY --from=builder /src/internship-2023 ./

EXPOSE 9090
CMD ["./internship-2023"]
