##------------------------------------------------------------------------------
## ML-Subber dockerfile
##
## @author     Lars Thoms <lars@thoms.io>
## @date       2023-05-08
##------------------------------------------------------------------------------

##------------------------------------------------------------------------------
## Build
##------------------------------------------------------------------------------

# Base image
FROM debian:stable-slim as build

# Environment variables during build
ENV DEBIAN_FRONTEND=noninteractive
ENV MAKEFLAGS="-j$(nproc)"

# Modify repository
RUN sed -i -e 's/ main/ main contrib/g' /etc/apt/sources.list

# Update base system
RUN apt-get update &&\
    apt-get dist-upgrade -y

# Install persistent packages
RUN apt-get install -y --no-install-recommends \
        ffmpeg \
        python3-minimal \
        python3-dev \
        python3-pkg-resources

# Install temporary packages
ARG BUILDDEPS="autoconf \
        automake \
        bzip2 \
        ca-certificates \
        g++ \
        gfortran \
        git \
        libatlas-base-dev \
        libtool \
        make \
        patch \
        python2-minimal \
        python3-pip \
        sox \
        subversion \
        unzip \
        wget"
RUN apt-get install -y --no-install-recommends ${BUILDDEPS}

# Install Subtitle2go
RUN git clone --depth=1 https://github.com/uhh-lt/subtitle2go.git /app &&\
    pip3 install --no-cache-dir --use-pep517 --no-compile --use-feature=fast-deps -r /app/requirements.txt

# Install Kaldi
WORKDIR /app
RUN sed -i -r 's@^\./configure .*$@\./configure --shared --static-math=yes --mathlib=ATLAS@' install_kaldi.sh &&\
    ./install_kaldi.sh

# Download language models
RUN python3 -m spacy download de_core_news_lg &&\
    python3 -m spacy download en_core_web_lg &&\
    ./download_models.sh

# Create data directory
RUN mkdir /data

# Add entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Delete temporary packages
RUN apt-get autoremove -y ${BUILDDEPS}

# Clean and harden container
COPY clean.sh /
RUN sh /clean.sh


##------------------------------------------------------------------------------
## Production
##------------------------------------------------------------------------------

# Copy results from build image
FROM scratch
COPY --from=build / /

# Base configuration
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
