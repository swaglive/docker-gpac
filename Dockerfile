ARG         base=ubuntu:22.04

###

FROM        ${base} as build

ARG         repo=gpac/gpac
ARG         version=
ARG         download_url=${version:+https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz}

RUN         apt-get update && \
            apt install -y \
                build-essential \
                cmake \
                dvb-apps \
                g++ \
                gcc \
                git \
                liba52-0.7.4-dev \
                libasound2-dev \
                libavcodec-dev \
                libavdevice-dev \
                libavformat-dev \
                libavutil-dev \
                libcaca-dev \
                libfaad-dev \
                libfreetype6-dev \
                libgl1-mesa-dev \
                libglu1-mesa-dev \
                libjack-dev \
                libjpeg62-dev \
                libmad0-dev \
                libnghttp2-dev \
                libogg-dev \
                libopenjp2-7-dev \
                libpng-dev \
                libpulse-dev \
                libsdl2-dev \
                libssl-dev \
                libswscale-dev \
                libtheora-dev \
                libvorbis-dev \
                libxv-dev \
                libxvidcore-dev \
                make \
                mesa-utils \
                pkg-config \
                scons \
                wget \
                x11proto-gl-dev \
                x11proto-video-dev \
                yasm \
                zlib1g-dev && \
            mkdir -p gpac_public && \
            wget -O - ${download_url} | tar xz --strip-components 1 -C gpac_public && \
            git clone --depth=1 https://github.com/gpac/deps_unix && \
            cd deps_unix && \
            git submodule update --depth=1 --init --recursive --force --checkout && \
            ./build_all.sh ${TARGETARCH}

WORKDIR     gpac_public

RUN         ./configure && \
            make -j$(nproc) && \
            make install

###

FROM        ${base}

ENV         LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib

ENTRYPOINT  ["gpac"]

RUN         apt-get update && \
            apt install -y \
                liba52-0.7.4 \
                libasound2 \
                libavcodec58 \
                libavdevice58 \
                libavformat58 \
                libavutil56 \
                libfaad2 \
                libfreetype6 \
                libgl1 \
                libglu1 \
                libglu1-mesa \
                libjack0 \
                libjpeg62 \
                libmad0 \
                libnghttp2-14 \
                libogg0 \
                libpng16-16 \
                libpulse0 \
                libsdl2-2.0-0 \
                libssl3 \
                libswscale5 \
                libtheora0 \
                libvorbis0a \
                libvorbisenc2 \
                libvorbisfile3 \
                libxv1 \
                libxvidcore4 \
                zlib1g

COPY        --from=build /usr/local/bin /usr/local/bin
COPY        --from=build /usr/local/include /usr/local/include
COPY        --from=build /usr/local/lib /usr/local/lib
COPY        --from=build /usr/local/share /usr/local/share
