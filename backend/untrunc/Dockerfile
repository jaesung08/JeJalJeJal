FROM ubuntu:bionic AS build
LABEL stage=intermediate
ARG FF_VER=3.3.9

# Set the repository to Kakao mirror
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# install packaged dependencies
RUN apt-get update && \
    apt-get -y install --no-install-recommends wget yasm g++ make git ca-certificates xz-utils && \
    [ "$FF_VER" = '3.3.9' ] && apt-get -y install --no-install-recommends libavformat-dev libavcodec-dev libavutil-dev || true && \
    rm -rf /var/lib/apt/lists/*

# copy code
ADD . /untrunc-src
WORKDIR /untrunc-src

# build untrunc
RUN /usr/bin/make FF_VER=$FF_VER && strip untrunc

FROM ubuntu:bionic
ARG FF_VER=3.3.9

# Set the repository to Kakao mirror for runtime stage
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get -y install --no-install-recommends python3-pip python3-setuptools && \
    [ "$FF_VER" = '3.3.9' ] && apt-get -y install --no-install-recommends libavformat57 libavcodec57 libavutil55 ffmpeg || true && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /untrunc-src/untrunc /bin/untrunc

# copy code
COPY requirement.txt requirement.txt
RUN python3 -m pip install -r requirement.txt
