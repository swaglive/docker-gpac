ARG         base=ubuntu:22.04
ARG         flavor=

###

###

FROM        ${base} as deps-minimal

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

FROM        ${base} as deps-full

ARG         version=
ARG         repo=gpac/gpac

RUN         apt-get update && \
            apt install -y \
                wget \
                build-essential \
                pkg-config \
                g++ \
                git \
                cmake \
                yasm \
                zlib1g-dev libfreetype6-dev libjpeg62-dev libpng-dev libmad0-dev libfaad-dev libogg-dev libvorbis-dev libtheora-dev liba52-0.7.4-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libavdevice-dev libnghttp2-dev libopenjp2-7-dev libcaca-dev libxv-dev x11proto-video-dev libgl1-mesa-dev libglu1-mesa-dev x11proto-gl-dev libxvidcore-dev libssl-dev libjack-dev libasound2-dev libpulse-dev libsdl2-dev dvb-apps mesa-utils && \
            wget -O - https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz | tar xz && \
            mv gpac-${version} gpac_public && \
            git clone --depth=1 https://github.com/gpac/deps_unix && \
            cd deps_unix && \
            git submodule update --depth=1 --init --recursive --force --checkout && \
            ./build_all.sh ${TARGETARCH}

###

FROM        deps-${flavor} as build

WORKDIR     gpac_public

RUN         ./configure && \
            make -j$(nproc) && \
            make install

###

FROM        ${base}

ENTRYPOINT  ["gpac"]

COPY        --from=build /usr/local/bin /usr/local/bin
COPY        --from=build /usr/local/include /usr/local/include
COPY        --from=build /usr/local/lib /usr/local/lib
COPY        --from=build /usr/local/share /usr/local/share
