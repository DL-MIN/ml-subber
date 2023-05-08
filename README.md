# ML Subber

Generate automated German subtitles using a machine learning generated language model.

*ML Subber* is assembled as a container with all dependencies, such as the language models.

**To get adequate results a further revision of the generated subtitles is recommended!**


## Resources

- [Kaldi](https://kaldi-asr.org)
- [Subtitle2go](https://github.com/uhh-lt/subtitle2go)


## Requirements

- Docker (or Podman as a drop-in replacement)


## Build

Build an image or use a prebuild image from our Container Registry in GitLab.

```shell
docker build -t ml-subber . --pull
```


## Usage

```shell
docker run --rm -it -v "$(pwd)":/data ml-subber video.mp4
```
