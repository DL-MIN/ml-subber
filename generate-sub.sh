#!/bin/sh
##------------------------------------------------------------------------------
## start subbing a video
##
## @author Lars Thoms
## @date   2021-12-09
##------------------------------------------------------------------------------

unset input output
input="$(readlink -f "${1}")"
output="${input%.*}.srt"

if [ "$#" -eq 1 ] && [ -f "${input}" ]
then
    touch "${output}"
    docker run --volume "${input}:/data/video.mp4:z" \
               --volume "${output}:/data/output/video.srt:z" \
               --user "$(id -u "${USER}"):$(id -g "${USER}")" \
               --cap-drop all \
               ml-subber \
               --file "/data/video.mp4"
else
    printf "Usage: %s [INFILE]\n\n" "${0}"
    printf "Example:\n %s video.mp4\n" "${0}"
fi
