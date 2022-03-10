#!/bin/sh

unset input output outputDir outputFile
input="$(readlink -f "${1}")"
output="${input%.*}.srt"
outputDir="$(dirname "${output}")"
outputFile="$(basename "${output%.*}.srt")"

case "${2}" in
    "deepspeech")
        python3 /opt/autosub/autosub/main.py --file "${input}" --format "srt" --engine "ds"
        cat "${outputDir}/output/${outputFile}" > "${output}"
        ;;
    "coqui")
        python3 /opt/autosub/autosub/main.py --file "${input}" --format "srt" --engine "stt"
        cat "${outputDir}/output/${outputFile}" > "${output}"
        ;;
    "kaldi")
        export KALDI_ROOT="/opt/subtitle2go/kaldi"
        export LD_LIBRARY_PATH="${KALDI_ROOT}/src/lib:${KALDI_ROOT}/tools/openfst-1.6.7/lib:${LD_LIBRARY_PATH}"
        export PATH="${KALDI_ROOT}/src/lmbin/:${KALDI_ROOT}/src/bin:${KALDI_ROOT}/tools/openfst/bin:${KALDI_ROOT}/src/fstbin/:${KALDI_ROOT}/src/gmmbin/:${KALDI_ROOT}/src/featbin/:${KALDI_ROOT}/src/lm/:${KALDI_ROOT}/src/sgmmbin/:${KALDI_ROOT}/src/sgmm2bin/:${KALDI_ROOT}/src/fgmmbin/:${KALDI_ROOT}/src/latbin/:${KALDI_ROOT}/src/nnetbin:${KALDI_ROOT}/src/nnet2bin/:${KALDI_ROOT}/src/online2bin/:${KALDI_ROOT}/src/ivectorbin/:${KALDI_ROOT}/src/kwsbin:${KALDI_ROOT}/src/nnet3bin:${KALDI_ROOT}/src/chainbin:${KALDI_ROOT}/tools/sph2pipe_v2.5/:${KALDI_ROOT}/src/rnnlmbin:${PWD}:${PATH}"
        cd /opt/subtitle2go || exit 1
        python3 subtitle2go.py --subtitle "srt" "${input}"
        ;;
esac
