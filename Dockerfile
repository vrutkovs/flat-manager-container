FROM registry.fedoraproject.org/fedora:32 as builder

RUN dnf update -y && \
    dnf install rust cargo postgresql-devel git-core -y && \
    dnf clean all

WORKDIR /code
RUN git clone -q -b 0.3.7 https://github.com/flatpak/flat-manager && \
    cd flat-manager && \
    cargo build --release

FROM registry.fedoraproject.org/fedora-minimal:32

COPY --from=builder /code/flat-manager/target/release/delta-generator-client /usr/local/bin
COPY --from=builder /code/flat-manager/target/release/flat-manager /usr/local/bin
COPY --from=builder /code/flat-manager/target/release/gentoken /usr/local/bin

CMD ["/usr/local/bin/flat-manager"]
