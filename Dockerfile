FROM debian:stable-slim

ENV PYTHONUNBUFFERED 1

# install packages
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    python3-minimal \
    python3-pip \
    ffmpeg

# copy program
COPY AutoSub/autosub /opt/autosub

# install python packages
RUN pip3 install --no-cache-dir \
    cycler \
    numpy \
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
    gdown

# create work directories
RUN mkdir -p /data/audio /data/output &&\
    chmod -R u=rwX,g=rwX,o=rwX /data

# download pretrained models
RUN gdown --output /data/AASHISHAG-v0.9.0.scorer --id 1BY-G-W3bwuVvEWy7Gg_sR7gMSqDmC1pi &&\
    gdown --output /data/AASHISHAG-v0.9.0.pbmm   --id 1tqO44LMOkYYxGcCABrfZF-RYJ9VileV0

WORKDIR /data
ENTRYPOINT ["python3", "/opt/autosub/main.py"]
