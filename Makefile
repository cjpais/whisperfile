#-*-mode:makefile-gmake;indent-tabs-mode:t;tab-width:8;coding:utf-8-*-┐
#── vi: set noet ft=make ts=8 sw=8 fenc=utf-8 :vi ────────────────────┘

SHELL = /bin/sh
MAKEFLAGS += --no-builtin-rules

.SUFFIXES:
.DELETE_ON_ERROR:
.FEATURES: output-sync

include build/config.mk
include build/rules.mk

include llamafile/BUILD.mk
include whisper.cpp/BUILD.mk

# the root package is `o//` by default
# building a package also builds its sub-packages
.PHONY: o/$(MODE)/
#o/$(MODE)/: o/$(MODE)/llama.cpp o/$(MODE)/llamafile
o/$(MODE)/: o/$(MODE)/llama.cpp o/$(MODE)/whisper.cpp o/$(MODE)/llamafile 

# for installing to `make PREFIX=/usr/local`
.PHONY: install
install:	llamafile/zipalign.1					\
		o/$(MODE)/llamafile/zipalign				\
		o/$(MODE)/whisper.cpp/server/server \
	mkdir -p $(PREFIX)/bin
	$(INSTALL) o/$(MODE)/llamafile/zipalign $(PREFIX)/bin/zipalign
	$(INSTALL) o/$(MODE)/whisper.cpp/server/server $(PREFIX)/bin/whisperfile
	$(INSTALL) build/llamafile-convert $(PREFIX)/bin/llamafile-convert
	$(INSTALL) build/llamafile-upgrade-engine $(PREFIX)/bin/llamafile-upgrade-engine
	mkdir -p $(PREFIX)/share/man/man1
	$(INSTALL) -m 0644 llamafile/zipalign.1 $(PREFIX)/share/man/man1/zipalign.1

.PHONY: check
check: o/$(MODE)/llamafile/check

include build/deps.mk
include build/tags.mk
