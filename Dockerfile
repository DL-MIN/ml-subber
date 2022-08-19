##------------------------------------------------------------------------------
## ML Subber DeepSpeech / Coqui STT containerfile
##
## @author Lars Thoms
## @date   2022-03-09
##------------------------------------------------------------------------------

FROM debian:stable-slim

ARG pykaldi_url="https://ltdata1.informatik.uni-hamburg.de/pykaldi/pykaldi-0.2.2-cp39-cp39-linux_x86_64.whl"
ARG pykaldi_file="pykaldi-0.2.2-cp39-cp39-linux_x86_64.whl"

ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND=noninteractive

# install packages
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        python-is-python3 \
        python3-minimal \
        python3-pip \
        python3-dev \
        g++ \
        make \
        automake \
        autoconf \
        patch \
        bzip2 \
        unzip \
        sox \
        gfortran \
        libtool \
        subversion \
        python2.7 \
        zlib1g-dev \
        libatlas-base-dev \
        git \
        wget \
        ffmpeg

# download pykaldi wheel
RUN wget "${pykaldi_url}" -O "/opt/${pykaldi_file}"

# install Python3 packages
RUN pip3 install --no-cache-dir \
        /opt/${pykaldi_file} \
        numpy \
        pyyaml \
        ffmpeg-python \
        theano \
        spacy \
        pdfplumber \
        cycler \
        deepspeech \
        joblib \
        kiwisolver \
        pydub \
        pyparsing \
        python-dateutil \
        scikit-learn \
        scipy \
        six \
        tqdm \
        stt \
        gdown \
        matplotlib \
        python_speech_features \
        audiosegment \
        rpunct \
        librosa

# clone repositories
RUN git clone --depth 1 https://github.com/abhirooptalasila/AutoSub.git /opt/autosub &&\
    git clone --depth 1 https://github.com/uhh-lt/subtitle2go.git /opt/subtitle2go &&\
    git clone --depth 1 https://github.com/ottokart/punctuator2.git /opt/subtitle2go/punctuator2 &&\
    git clone --depth 1 --branch pykaldi_02 https://github.com/pykaldi/kaldi.git /opt/subtitle2go/kaldi

# build kaldi
WORKDIR /opt/subtitle2go/kaldi/tools
RUN ./extras/check_dependencies.sh &&\
    make -j $(nproc) &&\
    cd ../src &&\
    ./configure --shared --static-math=yes --mathlib=ATLAS &&\
    make depend -j $(nproc) &&\
    make -j $(nproc)

# create work directories
RUN mkdir -p /data/audio /data/output /opt/subtitle2go/tmp &&\
    chmod -R u=rwX,g=rwX,o=rwX /data /opt/subtitle2go/tmp

# download pretrained models
WORKDIR /opt/subtitle2go
RUN ./download_models.sh &&\
    python3 -m spacy download de_core_news_lg &&\
    gdown --output /data/AASHISHAG-v0.9.0.scorer 1BY-G-W3bwuVvEWy7Gg_sR7gMSqDmC1pi &&\
    gdown --output /data/AASHISHAG-v0.9.0.pbmm   1tqO44LMOkYYxGcCABrfZF-RYJ9VileV0 &&\
    gdown --output /data/AASHISHAG-v0.9.0.tflite 1MnjoAklMtJlpG1eDP6uD_Izvt36nPpiq

# workaround
RUN sed -i "s/from . import models/import models/" /opt/subtitle2go/punctuator2/models.py &&\
    sed -i "s/from rpunct.rpunct /from rpunct /" /opt/subtitle2go/subtitle2go.py

COPY entrypoint.sh /entrypoint.sh
COPY theanorc /data/.theanorc

WORKDIR /data
ENV HOME=/data
ENTRYPOINT ["/entrypoint.sh"]
