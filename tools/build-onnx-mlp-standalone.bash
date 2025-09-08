#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ORTDIR="$(pwd)/onnx-mlp-standalone-src/onnxruntime-linux-x64-1.19.2"

g++ -O2 -std=c++14 \
  ./onnx-mlp-standalone-src/onnx-mlp-standalone.cpp \
  -I"${ORTDIR}/include" -L"${ORTDIR}/lib" \
  -lonnxruntime -Wl,-rpath,'$ORIGIN/onnx-mlp-standalone-src/onnxruntime-linux-x64-1.19.2/lib' \
  -o ./onnx-mlp-standalone

