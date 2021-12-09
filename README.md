# ML Subber

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
