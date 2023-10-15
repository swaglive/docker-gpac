ARG         base=ubuntu:22.04
ARG         flavor=minimal

###

FROM        ${base} as build-minimal

ARG         version=
ARG         repo=gpac/gpac

RUN         apt-get update && \
            apt install -y \
                wget \
                build-essential \
                pkg-config \
                zlib1g-dev && \
            wget -O - https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz | tar xz && \
            mv gpac-${version} gpac_public

###

FROM        build-${flavor} as build

WORKDIR     gpac_public

RUN         ./configure --static-bin && \
            make -j$(nproc) && \
            make install

###

FROM        ${base}

ENTRYPOINT  ["gpac"]

COPY        --from=build /usr/local/bin /usr/local/bin
COPY        --from=build /usr/local/include /usr/local/include
COPY        --from=build /usr/local/lib /usr/local/lib
COPY        --from=build /usr/local/share /usr/local/share
