# ML Subber

Generate automated German subtitles using one of the three implemented machine learning generated language model.

*ML Subber* is assembled as a container with all dependencies, such as the language models.
Videos can thus be easily subtitled using the small script `generate-sub.sh`.

**To get adequate results a further revision of the generated subtitles is recommended!**


## Resources

- [DeepSpeech](https://github.com/mozilla/DeepSpeech)
- [Coqui](https://coqui.ai)
- [Kaldi](https://kaldi-asr.org)
- [AutoSub](https://github.com/abhirooptalasila/AutoSub)
- [Subtitle2go](https://github.com/uhh-lt/subtitle2go)
- [Automatic Speech Recognition (ASR) - DeepSpeech German](https://github.com/AASHISHAG/deepspeech-german)


## Requirements

- Docker (or Podman as a drop-in replacement)
- Bash (optional)


## Build

Build an image or use a prebuild image from our Container Registry in GitLab.

```shell
docker build -t ml-subber . --pull
```


## Usage

```
Usage: ./generate-sub.sh [FILE] [ENGINE]

File:
  ./generate-sub.sh video.mp4 coqui

Engines:
  deepspeech (Mozilla DeepSpeech)
  coqui (Coqui STT)
  kaldi (Kaldi ASR)
```
