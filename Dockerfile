FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache curl tar xcaddy

ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
ENV CGO_ENABLED=0

RUN if [ "$TARGETARCH" = "arm" ]; then \
        VARIANT=$(echo "$TARGETPLATFORM" | awk -F/ '{print $3}'); \
        if [ -n "$VARIANT" ]; then \
            export GOARM="${VARIANT#v}"; \
        fi; \
    fi

WORKDIR /src

RUN xcaddy build --output /out/caddy

FROM busybox:stable-glibc

COPY --from=builder /out/caddy /usr/bin/caddy

EXPOSE 80 443
ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile"]
