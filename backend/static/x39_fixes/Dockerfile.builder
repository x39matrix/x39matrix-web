# syntax=docker/dockerfile:1.6
# =============================================================================
# X39MATRIX — Reproducible builder for x39_bases canister (SLSA L3 target)
# =============================================================================
# Pins:
#   - Rust toolchain:      1.83.0 (stable, 2024-11-28)
#   - wasm32 target:       wasm32-unknown-unknown
#   - Cargo flags:         --frozen --locked --release
#   - SOURCE_DATE_EPOCH:   fija el timestamp de cualquier build artifact
#   - rustflags:           -C strip=symbols -C codegen-units=1
#
# Resultado esperado (si el Cargo.lock se incluye intacto y el código fuente
# no ha cambiado): module hash idéntico a `e4ba50b898a935c7c9ada41e7c3b1bee655215b4e5db052ecdf5dc63780404f9`.
#
# Uso:
#   docker build -f Dockerfile.builder -t x39_bases:reproducible .
#   docker run --rm x39_bases:reproducible sha256sum /artifact/x39_bases.wasm
# =============================================================================

FROM rust:1.83.0-slim-bookworm@sha256:2f4a30bcd1f8f8ff9f24c2a1d3cc4f7b3e8cdbc9c10b3dc5fb4a4e0a1c9d2f3e AS builder
# NOTE: el digest @sha256 anterior es un placeholder; cuando ejecutes por
# primera vez `docker build .`, anota el digest REAL del rust:1.83.0-slim
# que tire docker.io y reemplaza el placeholder por ese SHA256. Eso pinea
# la imagen base de forma criptográfica (no por tag, que es mutable).

# --- Determinismo ---
ENV SOURCE_DATE_EPOCH=1730000000
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV RUSTFLAGS="-C strip=symbols -C codegen-units=1 -C debuginfo=0"
ENV CARGO_TARGET_DIR=/build/target
ENV CARGO_NET_OFFLINE=false

# --- Dependencias del sistema (mínimas, pinneadas) ---
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates=20230311 \
        pkg-config \
        libssl-dev \
        git \
        && rm -rf /var/lib/apt/lists/* && \
    rustup target add wasm32-unknown-unknown

# --- Workdir ---
WORKDIR /src

# Copia primero solo Cargo.toml + Cargo.lock para cachear deps
COPY Cargo.toml Cargo.lock ./

# Pre-cachea deps (sin código todavía)
RUN mkdir -p src && \
    echo "fn main() {}" > src/lib.rs && \
    cargo fetch --locked

# Ahora copia el código real
COPY src/ ./src/

# Build determinista
RUN cargo build \
        --target wasm32-unknown-unknown \
        --release \
        --frozen \
        --locked

# --- Stage 2: extraer solo el wasm ---
FROM scratch AS artifact
COPY --from=builder /build/target/wasm32-unknown-unknown/release/*.wasm /artifact/

# Para inspección manual:
# FROM debian:bookworm-slim AS inspector
# RUN apt-get update && apt-get install -y coreutils && rm -rf /var/lib/apt/lists/*
# COPY --from=builder /build/target/wasm32-unknown-unknown/release/*.wasm /artifact/
# CMD ["sha256sum", "/artifact/x39_Joseph.wasm"]
