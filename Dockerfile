# Build Stage
FROM --platform=linux/amd64 ubuntu:22.04 AS builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y make g++ cmake patchelf

## Add source code to the build stage.
ADD . /p7zip
WORKDIR /p7zip

## Build the standalone 7zz binary (produces _o/bin/7zz)
RUN cd CPP/7zip/Bundles/Alone2 && make -f makefile.gcc

## Build the 7z.so format plugin (produces _o/lib/7z.so)
RUN cd CPP/7zip/Bundles/Format7zF && make -f makefile.gcc

## Collect outputs into bin/
RUN mkdir -p bin && \
    cp CPP/7zip/Bundles/Alone2/_o/bin/7zz bin/7z && \
    cp CPP/7zip/Bundles/Format7zF/_o/lib/7z.so bin/7z.so

# Package Stage
FROM --platform=linux/amd64 ubuntu:22.04

COPY --from=builder /p7zip/bin/7z /
COPY --from=builder /p7zip/bin/7z.so /
