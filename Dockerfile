FROM alpine:3.10

MAINTAINER cavemandaveman <cavemandaveman@protonmail.com>

# ARG S6_VERSION="v1.18.0.0"
ARG S6_VERSION="v1.22.1.0"
ARG CONSUL_TEMPLATE_VERSION="0.23.0"
ARG CONSUL_TEMPLATE_SHA256="8f7fa4492d29930f4d621b8643d734cb3f4318c32cc088f7c68519ccd9f6f33f"

RUN set -x && \
    apk --no-cache add haproxy && \
    apk --no-cache add --virtual .install-deps \
      openssl \
      gnupg && \
    export GNUPGHOME="$(mktemp -d)" WGETHOME="$(mktemp -d)" && \
    wget -q "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz.sig" \
      "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz" \
      "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" -P "${WGETHOME}" && \
    wget -qO - https://keybase.io/justcontainers/key.asc | gpg --import && \
    gpg --verify "${WGETHOME}/s6-overlay-amd64.tar.gz.sig" "${WGETHOME}/s6-overlay-amd64.tar.gz" && \
    tar -zxf "${WGETHOME}/s6-overlay-amd64.tar.gz" -C / && \
    sha256sum "${WGETHOME}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" && \
    echo "${CONSUL_TEMPLATE_SHA256}  ${WGETHOME}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c && \
    unzip -qd "/bin/" "${WGETHOME}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" && \
    rm -rf "${GNUPGHOME}" "${WGETHOME}" && \
    apk del .install-deps

COPY etc/ /etc/
COPY bin/ /bin/

ENTRYPOINT ["/init"]
