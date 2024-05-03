# pull base image
FROM ubuntu:bionic AS build
LABEL stage=intermediate
ARG FF_VER=shared

# install packaged dependencies
RUN apt-get update && [ "$FF_VER" = 'shared' ] && \
	apt-get -y install --no-install-recommends libavformat-dev libavcodec-dev libavutil-dev g++ make git || \
	apt-get -y install --no-install-recommends yasm wget g++ make git ca-certificates xz-utils && \
	rm -rf /var/lib/apt/lists/*

# copy code
ADD . /untrunc-src
WORKDIR /untrunc-src

# build untrunc
#RUN /usr/bin/g++ -o untrunc *.cpp -lavformat -lavcodec -lavutil
RUN /usr/bin/make FF_VER=$FF_VER && strip untrunc


# deliver clean image
FROM ubuntu:bionic
ARG FF_VER=shared

RUN apt-get update && [ "$FF_VER" = 'shared' ] && \
	apt-get -y install --no-install-recommends libavformat57 libavcodec57 libavutil55 python3-setuptools python3-pip ffmpeg && \
	rm -rf /var/lib/apt/lists/* || true
COPY --from=build /untrunc-src/untrunc /bin/untrunc

# copy code
COPY ./requirement.txt requirement.txt
RUN pip3 install -r requirement.txt

# 생략
# RUN useradd voicepassing
# USER voicepassing


# # Base image and build environment setup
# FROM ubuntu:bionic AS build
# LABEL stage=intermediate

# # Install build dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libavformat-dev \
#     libavcodec-dev \
#     libavutil-dev \
#     g++ \
#     make \
#     git \
#     && rm -rf /var/lib/apt/lists/*

# # Copy source code into the container
# COPY . /untrunc-src
# WORKDIR /untrunc-src

# # Build untrunc
# RUN make && strip untrunc

# # Final stage: setup the runtime environment
# FROM ubuntu:bionic
# COPY --from=build /untrunc-src/untrunc /usr/local/bin/untrunc

# # Install runtime dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libavformat57 \
#     libavcodec57 \
#     libavutil55 \
#     && rm -rf /var/lib/apt/lists/*

# # Set entrypoint to untrunc executable
# ENTRYPOINT ["untrunc"]
