FROM docker.io/library/debian:latest AS builder

ARG VERSION=3.4.4

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        git \
        python3 \
        jq \
        sudo && \
    rm -rf /var/lib/apt/lists/* && \
    # Verify ip exists
    [ -x "$(command -v ip)" ] || (echo "ERROR: ip command not found!" && exit 1)

WORKDIR /n3n

RUN  \
    git clone https://github.com/n42n/n3n.git . && \
    git checkout ${VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make clean all


FROM docker.io/library/debian:latest

RUN apt-get update && apt-get install -y --no-install-recommends iproute2

COPY docker-start.sh docker-start.sh
COPY --from=builder /n3n/apps/n3n-edge /usr/local/bin/n3n-edge
COPY --from=builder /n3n/apps/n3n-supernode /usr/local/bin/n3n-supernode

VOLUME [ "/etc/n3n" ]

RUN chmod +x docker-start.sh

ENTRYPOINT ["./docker-start.sh"]
