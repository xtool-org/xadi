FROM swift:6.3-jammy

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        build-essential \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsS https://dlang.org/install.sh | bash -s ldc

WORKDIR /workspace
COPY . .

RUN /bin/bash -c 'source $(/root/dlang/install.sh ldc -a) && make test'
