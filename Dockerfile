FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    bash \
    git \
    gawk \
    sed \
    grep \
    coreutils \
    findutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["/bin/bash"]