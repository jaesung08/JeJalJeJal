# Stage 1: Build stage
FROM ubuntu:bionic AS build
LABEL stage=intermediate
ARG FF_VER=3.3.9

# Set the repository to Kakao mirror
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# Install packaged dependencies
RUN apt-get update && \
    apt-get -y install --no-install-recommends wget yasm g++ make git ca-certificates xz-utils python3.7 python3.7-distutils python3-pip && \
    [ "$FF_VER" = '3.3.9' ] && apt-get -y install --no-install-recommends libavformat-dev libavcodec-dev libavutil-dev || true && \
    rm -rf /var/lib/apt/lists/*

# Make Python 3.7 the default Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

# Ensure pip is upgraded and set up correctly for Python 3.7
RUN python3 -m pip install --upgrade pip

# Copy code
ADD . /untrunc-src
WORKDIR /untrunc-src

# Build untrunc
RUN /usr/bin/make FF_VER=$FF_VER && strip untrunc

# Stage 2: Runtime stage
FROM ubuntu:bionic
ARG FF_VER=3.3.9

# Set the repository to Kakao mirror for runtime stage
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get -y install --no-install-recommends python3.7 python3.7-distutils python3-pip && \
    [ "$FF_VER" = '3.3.9' ] && apt-get -y install --no-install-recommends libavformat57 libavcodec57 libavutil55 ffmpeg || true && \
    rm -rf /var/lib/apt/lists/*

# Make Python 3.7 the default Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

# Ensure pip is upgraded and set up correctly for Python 3.7
RUN python3 -m pip install --upgrade pip

# Copy built untrunc
COPY --from=build /untrunc-src/untrunc /bin/untrunc

# Copy app.py and requirements file to the root of the container
COPY app.py /app.py
COPY requirement.txt /requirement.txt

# Install Python dependencies
RUN python3 -m pip install -r /requirement.txt
