#-*-mode:makefile-gmake;indent-tabs-mode:t;tab-width:8;coding:utf-8-*-┐
#── vi: set noet ft=make ts=8 sw=8 fenc=utf-8 :vi ────────────────────┘

PKGS += WHISPER_CPP

WHISPER_CPP_FILES := $(wildcard whisper.cpp/*.*)
# WHISPER_CPP_HDRS = $(filter %.h,$(WHISPER_CPP_FILES))
WHISPER_CPP_HDRS = $(filter %.h %.hpp,$(WHISPER_CPP_FILES))
WHISPER_CPP_INCS = $(filter %.inc,$(WHISPER_CPP_FILES))
WHISPER_CPP_SRCS_C = $(filter %.c,$(WHISPER_CPP_FILES))
WHISPER_CPP_SRCS_CPP = $(filter %.cpp,$(WHISPER_CPP_FILES))
WHISPER_CPP_SRCS = $(WHISPER_CPP_SRCS_C) $(WHISPER_CPP_SRCS_CPP)

WHISPER_CPP_OBJS =					\
	$(LLAMAFILE_OBJS)				\
	$(WHISPER_CPP_SRCS_C:%.c=o/$(MODE)/%.o)		\
	$(WHISPER_CPP_SRCS_CPP:%.cpp=o/$(MODE)/%.o)	\
	$(WHISPER_CPP_FILES:%=o/$(MODE)/%.zip.o)

o/$(MODE)/whisper.cpp/whisper.cpp.a: $(WHISPER_CPP_OBJS)

include whisper.cpp/server/BUILD.mk

$(WHISPER_CPP_OBJS): private				\
		CCFLAGS +=				\
			-DNDEBUG			\
			-DGGML_MULTIPLATFORM		\
			-DGGML_USE_LLAMAFILE

o/$(MODE)/whisper.cpp/ggml-alloc.o			\
o/$(MODE)/whisper.cpp/ggml-backend.o			\
o/$(MODE)/whisper.cpp/grammar-parser.o			\
o/$(MODE)/whisper.cpp/json-schema-to-grammar.o		\
o/$(MODE)/whisper.cpp/whisper.o				\
o/$(MODE)/whisper.cpp/stb_image.o				\
o/$(MODE)/whisper.cpp/unicode.o				\
o/$(MODE)/whisper.cpp/sampling.o				\
o/$(MODE)/whisper.cpp/ggml-alloc.o			\
o/$(MODE)/whisper.cpp/common.o: private			\
		CCFLAGS += -Os

o/$(MODE)/whisper.cpp/ggml-quants.o: private CXXFLAGS += -Os
o/$(MODE)/whisper.cpp/ggml-quants-amd-avx.o: private TARGET_ARCH += -Xx86_64-mtune=sandybridge
o/$(MODE)/whisper.cpp/ggml-quants-amd-avx2.o: private TARGET_ARCH += -Xx86_64-mtune=skylake -Xx86_64-mf16c -Xx86_64-mfma -Xx86_64-mavx2
o/$(MODE)/whisper.cpp/ggml-quants-amd-avx512.o: private TARGET_ARCH += -Xx86_64-mtune=cannonlake -Xx86_64-mf16c -Xx86_64-mfma -Xx86_64-mavx2 -Xx86_64-mavx512f

o/$(MODE)/whisper.cpp/ggml-vector.o: private CXXFLAGS += -Os
o/$(MODE)/whisper.cpp/ggml-vector-amd-avx.o: private TARGET_ARCH += -Xx86_64-mtune=sandybridge
o/$(MODE)/whisper.cpp/ggml-vector-amd-fma.o: private TARGET_ARCH += -Xx86_64-mtune=bdver2 -Xx86_64-mfma
o/$(MODE)/whisper.cpp/ggml-vector-amd-f16c.o: private TARGET_ARCH += -Xx86_64-mtune=ivybridge -Xx86_64-mf16c
o/$(MODE)/whisper.cpp/ggml-vector-amd-avx2.o: private TARGET_ARCH += -Xx86_64-mtune=skylake -Xx86_64-mf16c -Xx86_64-mfma -Xx86_64-mavx2
o/$(MODE)/whisper.cpp/ggml-vector-amd-avx512.o: private TARGET_ARCH += -Xx86_64-mtune=cannonlake -Xx86_64-mf16c -Xx86_64-mfma -Xx86_64-mavx2 -Xx86_64-mavx512f
o/$(MODE)/whisper.cpp/ggml-vector-amd-avx512bf16.o: private TARGET_ARCH += -Xx86_64-mtune=znver4 -Xx86_64-mf16c -Xx86_64-mfma -Xx86_64-mavx2 -Xx86_64-mavx512f -Xx86_64-mavx512vl -Xx86_64-mavx512bf16
o/$(MODE)/whisper.cpp/ggml-vector-arm82.o: private TARGET_ARCH += -Xaarch64-march=armv8.2-a+fp16

$(WHISPER_CPP_OBJS): whisper.cpp/BUILD.mk

.PHONY: o/$(MODE)/whisper.cpp
o/$(MODE)/whisper.cpp: 					\
		o/$(MODE)/whisper.cpp/server		