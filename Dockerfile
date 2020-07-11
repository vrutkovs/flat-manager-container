FROM registry.fedoraproject.org/fedora:32 as builder

RUN dnf update -y && \
    dnf install rust cargo postgresql-devel git-core -y && \
    dnf clean all

WORKDIR /code
RUN git clone -q -b 0.3.7 https://github.com/flatpak/flat-manager && \
    cd flat-manager && \
    cargo build --release

FROM registry.fedoraproject.org/fedora:32

RUN dnf update -y && \
    dnf install libpq flatpak gnupg2 -y && \
    dnf clean all

# Add dedicated flatmanager user
RUN adduser -u 1000 -d /var/lib/flat-manager -m flatmanager

COPY --from=builder /code/flat-manager/target/release/delta-generator-client /usr/local/bin
COPY --from=builder /code/flat-manager/target/release/flat-manager /usr/local/bin
COPY --from=builder /code/flat-manager/target/release/gentoken /usr/local/bin

USER 1000

CMD ["/usr/local/bin/flat-manager"]
