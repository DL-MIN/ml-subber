# ML Subber

Generate automated German subtitles using a machine learning generated language model.

*ML Subber* is assembled as a container with all dependencies, such as the language models.
Videos can thus be easily subtitled using the small script `generate-sub.sh`.

**To get adequate results a further revision of the generated subtitles is recommended!**


## Resources

- [AutoSub](https://github.com/abhirooptalasila/AutoSub)
- [Automatic Speech Recognition (ASR) - DeepSpeech German](https://github.com/AASHISHAG/deepspeech-german)


## Requirements

- Docker (or Podman as a drop-in replacement)
- POSIX Shell (e.g. Dash or Bash, optional)


## Build

Build an image or use a prebuild image from our Container Registry in GitLab.

```shell
docker build -t ml-subber .
```


## Usage

```shell
./generate-sub.sh video.mp4
```
