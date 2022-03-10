#!/bin/bash
##------------------------------------------------------------------------------
## generate German subtitle of a video
##
## @author Lars Thoms
## @date   2022-03-09
##------------------------------------------------------------------------------

unset input output engine
input="$(readlink -f "${1}")"
output="${input%.*}.srt"
engine="${2}"

if [ "$#" -eq 2 ] && [ -f "${input}" ]
then
    touch "${output}"
    docker run --volume "${input}:/data/video.mp4:z" \
               --volume "${output}:/data/video.srt:z" \
               --user "$(id -u "${USER}"):$(id -g "${USER}")" \
               --cap-drop all \
               ml-subber \
               "/data/video.mp4" \
               "${engine}"
else
    printf "Usage: %s [FILE] [ENGINE]\n\n" "${0}"
    printf "File:\n  %s video.mp4 ds\n\n" "${0}"
    printf "Engines:\n  deepspeech (Mozilla DeepSpeech)\n  coqui (Coqui STT)\n  kaldi (Kaldi ASR)\n"
fi
