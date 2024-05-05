FROM ubuntu:bionic AS build
LABEL stage=intermediate
ARG FF_VER=3.3.9

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

RUN apt-get update && apt-get -y install --no-install-recommends python3-pip python3-setuptools && \
    [ "$FF_VER" = '3.3.9' ] && apt-get -y install --no-install-recommends libavformat57 libavcodec57 libavutil55 ffmpeg || true && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /untrunc-src/untrunc /bin/untrunc

# copy code
COPY requirement.txt requirement.txt
RUN python3 -m pip install -r requirement.txt

# # pull base image
# FROM ubuntu:bionic AS build
# LABEL stage=intermediate
# ARG FF_VER=shared

# # install packaged dependencies
# RUN apt-get update && [ "$FF_VER" = 'shared' ] && \
# 	apt-get -y install --no-install-recommends libavformat-dev libavcodec-dev libavutil-dev g++ make git || \
# 	apt-get -y install --no-install-recommends yasm wget g++ make git ca-certificates xz-utils && \
# 	rm -rf /var/lib/apt/lists/*

# # copy code
# ADD . /untrunc-src
# WORKDIR /untrunc-src

# # build untrunc
# #RUN /usr/bin/g++ -o untrunc *.cpp -lavformat -lavcodec -lavutil
# RUN /usr/bin/make FF_VER=$FF_VER && strip untrunc


# # deliver clean image
# FROM ubuntu:bionic
# ARG FF_VER=shared

# RUN apt-get update && [ "$FF_VER" = 'shared' ] && \
# 	apt-get -y install --no-install-recommends libavformat57 libavcodec57 libavutil55 python3-setuptools python3-pip ffmpeg && \
# 	rm -rf /var/lib/apt/lists/* || true
# COPY --from=build /untrunc-src/untrunc /bin/untrunc

# # copy code
# COPY ./requirement.txt requirement.txt
# RUN pip3 install -r requirement.txt

# 생략
# RUN useradd voicepassing
# USER voicepassing