#!/bin/bash

make -j8
ls -lh o/whisper.cpp/server/server
cp o/whisper.cpp/server/server whisper-tiny-q8.llamafile
ls -lh whisper-tiny-q8.llamafile
zipalign -j0 whisper-tiny-q8.llamafile ggml-tiny.en-q8_0.bin .args
ls -lh whisper-tiny-q8.llamafile

cp whisper-tiny-q8.llamafile ../

./whisper-tiny-q8.llamafile