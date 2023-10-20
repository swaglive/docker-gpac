ARG         base=ubuntu:22.04
ARG         flavor=

###

FROM        ${base} as deps-slim

ARG         repo=gpac/gpac
ARG         version=
ARG         download_url=${version:+https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz}

RUN         apt-get update && \
            apt install -y \
                wget \
                build-essential \
                pkg-config \
                zlib1g-dev && \
            mkdir -p gpac_public && \
            wget -O - ${download_url} | tar xz --strip-components 1 -C gpac_public

###

FROM        ${base} as deps-full

ARG         repo=gpac/gpac
ARG         version=
ARG         download_url=${version:+https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz}

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
            mkdir -p gpac_public && \
            wget -O - ${download_url} | tar xz --strip-components 1 -C gpac_public && \
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

FROM        ${base} as runtime-full

RUN         apt-get update && \
            apt install -y \
                zlib1g \
                libfreetype6 \
                libjpeg62 \
                libmad0 \
                libfaad2 \
                libogg0 \
                libvorbis0a libvorbisenc2 libvorbisfile3 \
                libtheora0 \
                liba52-0.7.4 \
                libavcodec58 \
                libavformat58 \
                libavutil56 \
                libswscale5 \
                libavdevice58 \
                libnghttp2-14 \
                libgl1 \
                libglu1

###

FROM        ${base} as runtime-slim

###

FROM        runtime-${flavor}

ENV         LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib

ENTRYPOINT  ["gpac"]

COPY        --from=build /usr/local/bin /usr/local/bin
COPY        --from=build /usr/local/include /usr/local/include
COPY        --from=build /usr/local/lib /usr/local/lib
COPY        --from=build /usr/local/share /usr/local/share