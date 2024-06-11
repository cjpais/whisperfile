#!/bin/sh

TMP=$(mktemp -d) || exit

cp whisper.cpp/ggml-cuda.cu \
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
   "$TMP" || exit

cd "$TMP"

/usr/local/cuda/bin/nvcc \
  --shared \
  -arch=all-major \
  --forward-unknown-to-host-compiler \
  --compiler-options "-fPIC -O2" \
  -DNDEBUG \
  -DGGML_BUILD=1 \
  -DGGML_SHARED=1 \
  -DGGML_CUDA_MMV_Y=1 \
  -DGGML_MULTIPLATFORM \
  -DGGML_CUDA_DMMV_X=32 \
  -DK_QUANTS_PER_ITERATION=2 \
  -DGGML_CUDA_PEER_MAX_BATCH_SIZE=128 \
  -DGGML_MINIMIZE_CODE_SIZE \
  -DGGML_USE_TINYBLAS \
  -o ~/ggml-cuda.so \
  ggml-cuda.cu \
  -lcuda
