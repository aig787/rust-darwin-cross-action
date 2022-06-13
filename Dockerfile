FROM liushuyu/osxcross as builder

RUN cd /tmp && \
    git clone https://github.com/hogliux/bomutils.git && \
    cd bomutils && \
    make && \
    make install

FROM ubuntu:focal-20220531
ARG TOOLCHAIN

COPY --from=builder /opt/osxcross /opt/osxcross
COPY --from=builder /usr/bin/mkbom /usr/bin/mkbom
COPY --from=builder /usr/bin/dumpbom /usr/bin/dumpbom
COPY --from=builder /usr/bin/lsbom /usr/bin/lsbom
COPY --from=builder /usr/bin/ls4mkbom /usr/bin/ls4mkbom

RUN apt-get update --yes \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
    curl \
    ca-certificates \
    clang \
    cmake \
    git \
    libz-dev \
    && rm -rf /var/lib/apt/lists/*

ENV RUST_VERSION=${TOOLCHAIN}
ENV DARWIN_VERSION="18"
ENV CC=o64-clang
ENV CXX=o64-clang++
ENV RUSTUP_HOME=/opt/rust/rustup
ENV CARGO_HOME=/opt/rust/cargo
ENV PATH=$PATH:/opt/osxcross/bin:/usr/local/bomutils/bin:${CARGO_HOME}:${RUSTUP_HOME}

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION -t x86_64-apple-darwin
ADD cargo-config.toml $CARGO_HOME/config
RUN sed -i "s/VERSION/$DARWIN_VERSION/g" ${CARGO_HOME}/config
RUN chmod -R 777 $CARGO_HOME

RUN mkdir -p /github
RUN useradd -m -d /github/home -u 1001 github

ADD entrypoint.sh cleanup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/cleanup.sh

USER github
WORKDIR /github/home

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
