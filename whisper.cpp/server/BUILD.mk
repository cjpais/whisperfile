#-*-mode:makefile-gmake;indent-tabs-mode:t;tab-width:8;coding:utf-8-*-┐
#── vi: set noet ft=make ts=8 sw=8 fenc=utf-8 :vi ────────────────────┘

PKGS += WHISPER_CPP_SERVER

WHISPER_CPP_SERVER_FILES := $(wildcard whisper.cpp/server/*)
WHISPER_CPP_SERVER_HDRS = $(filter %.h,$(WHISPER_CPP_SERVER_FILES))
WHISPER_CPP_SERVER_SRCS = $(filter %.cpp,$(WHISPER_CPP_SERVER_FILES))
WHISPER_CPP_SERVER_OBJS = $(WHISPER_CPP_SERVER_SRCS:%.cpp=o/$(MODE)/%.o)

# o/$(MODE)/whisper.cpp/server/quantize.1.asc.zip.o	
o/$(MODE)/whisper.cpp/server/server:					\
		o/$(MODE)/whisper.cpp/server/server.o			\
		o/$(MODE)/whisper.cpp/whisper.cpp.a

.PHONY: o/$(MODE)/whisper.cpp/server
o/$(MODE)/whisper.cpp/server:						\
		o/$(MODE)/whisper.cpp/server/server

# o/$(MODE)/whisper.cpp/server/impl.o: private CXXFLAGS += -O1

# o/$(MODE)/whisper.cpp/server/server.a:				\
# 		$(WHISPER_CPP_SERVER_OBJS)

# o/$(MODE)/whisper.cpp/server/server.o: private			\
# 		CCFLAGS += -Os

# $(WHISPER_CPP_SERVER_OBJS): whisper.cpp/server/BUILD.mk

# .PHONY: o/$(MODE)/whisper.cpp/server
# o/$(MODE)/whisper.cpp/server:					\
# 		o/$(MODE)/whisper.cpp/server/server.a
