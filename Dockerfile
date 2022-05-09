# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /rust-protobuf
WORKDIR /rust-protobuf

RUN cd test-crates/protobuf-fuzz/fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04

COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/all /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/empty_message /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/empty_message_read /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/map /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/map_read /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/repeated /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/repeated_read /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/singular /
COPY --from=builder rust-protobuf/test-crates/protobuf-fuzz/fuzz/target/x86_64-unknown-linux-gnu/release/singular_read /


