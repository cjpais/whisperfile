#!/bin/sh
set -x
HOST=${1:?HOST}

ssh $HOST mkdir -p lfbuild
scp whisper.cpp/ggml-cuda.cu \
    whisper.cpp/ggml-cuda.h \
    whisper.cpp/ggml-impl.h \
    whisper.cpp/ggml-alloc.h \
    whisper.cpp/ggml-common.h \
    whisper.cpp/ggml-backend.h \
    whisper.cpp/ggml-backend-impl.h \
    whisper.cpp/ggml.h \
    llamafile/tinyblas.h \
    llamafile/tinyblas.cu \
    llamafile/llamafile.h \
    llamafile/rocm.bat \
    llamafile/rocm.sh \
    llamafile/cuda.bat \
    llamafile/cuda.sh \
    $HOST:lfbuild/
