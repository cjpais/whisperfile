#!/bin/sh
# Compiles distributable DLL for AMD GPU support
#
# The artifact will only depend on KERNEL32.DLL and NVCUDA.DLL.
# NVCUDA DLLs are provided by the installation of the windows GPU
# driver on a Windows system that has a CUDA-capable GPU installed.

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

hipcc \
  -O3 \
  -fPIC \
  -shared \
  -DNDEBUG \
  -DGGML_BUILD=1 \
  -DGGML_SHARED=1 \
  -Wno-return-type \
  -Wno-unused-result \
  -DGGML_CUDA_MMV_Y=1 \
  -DGGML_MULTIPLATFORM \
  -DGGML_USE_HIPBLAS=1 \
  -DGGML_USE_TINYBLAS=1 \
  -DGGML_CUDA_DMMV_X=32 \
  -DK_QUANTS_PER_ITERATION=2 \
  -DGGML_MINIMIZE_CODE_SIZE=1 \
  -DGGML_CUDA_PEER_MAX_BATCH_SIZE=128 \
  --offload-arch=gfx1100,gfx1031,gfx1030,gfx1032,gfx906,gfx1101,gfx1102,gfx1103 \
  -o ~/ggml-rocm.so \
  ggml-cuda.cu
