ARG GO_VERSION=1.18-rc

FROM golang:${GO_VERSION}-alpine AS builder

RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group
RUN apk add --no-cache ca-certificates git

WORKDIR /src
COPY ./ ./

ENV CGO_ENABLED=0
RUN go build -o /httpstatic .

FROM ubuntu:22.04 AS ubuntu-source

RUN apt-get update
RUN apt-get install -y mime-support shared-mime-info

FROM scratch AS final

COPY --from=ubuntu-source /usr/share/mime/globs2 /usr/share/mime/globs2
COPY --from=ubuntu-source /etc/mime.types /etc/mime.types
COPY --from=builder /user/group /user/passwd /etc/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /httpstatic /httpstatic

USER nobody:nobody

ENTRYPOINT ["/httpstatic"]
