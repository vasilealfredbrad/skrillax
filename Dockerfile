FROM rust:1.82-bookworm as builder

WORKDIR /usr/src/skrillax
COPY . .

RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN cargo install --locked --path ./silkroad-agent
RUN cargo install --locked --path ./silkroad-gateway

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/silkroad-agent /usr/local/bin/silkroad-agent
COPY --from=builder /usr/local/cargo/bin/silkroad-gateway /usr/local/bin/silkroad-gateway

WORKDIR /opt/skrillax

COPY configs /opt/skrillax/configs/
COPY ./scripts/docker-run.sh /opt/skrillax/run.sh

CMD ["/opt/skrillax/run.sh"]