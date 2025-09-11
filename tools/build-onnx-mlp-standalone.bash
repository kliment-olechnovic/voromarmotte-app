#!/bin/bash

cd "$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

DETECTED_OS=""

if [[ "$OSTYPE" == darwin* ]]
then
	DETECTED_OS="macos"
elif [[ "$OSTYPE" == linux* ]]
then
	DETECTED_OS="linux"
fi

if [ -z "$DETECTED_OS" ]
then
	UNAME_OSTYPE="$(uname -s)"
	
	if [[ "$UNAME_OSTYPE" == Darwin* ]]
	then
		DETECTED_OS="macos"
	elif [[ "$UNAME_OSTYPE" == Linux* ]]
	then
		DETECTED_OS="linux"
	fi
fi

if [ "$DETECTED_OS" != "linux" ] && [ "$DETECTED_OS" != "macos" ]
then
	echo "Could not detect a supported OS for building the 'onnx-mlp-standalone' tool - it can only be built on Linux or macOS systems." 
	exit 1
fi

if [ "$DETECTED_OS" == "linux" ]
then
	ORTDIR="$(pwd)/onnx-mlp-standalone-src/onnxruntime-linux-x64-1.19.2"
	
	if [ ! -d "$ORTDIR" ]
	then
		cd "$(dirname ${ORTDIR})"
		tar -xf "$(basename ${ORTDIR}).tgz"
		cd - &> /dev/null
	fi
	
	g++ -O2 -std=c++14 \
	  ./onnx-mlp-standalone-src/onnx-mlp-standalone.cpp \
	  -I"${ORTDIR}/include" -L"${ORTDIR}/lib" \
	  -lonnxruntime -Wl,-rpath,'$ORIGIN/onnx-mlp-standalone-src/onnxruntime-linux-x64-1.19.2/lib' \
	  -o ./onnx-mlp-standalone
elif [ "$DETECTED_OS" == "macos" ]
then
	ORTDIR="$(pwd)/onnx-mlp-standalone-src/onnxruntime-osx-universal2-1.19.2"
	
	if [ ! -d "$ORTDIR" ]
	then
		cd "$(dirname ${ORTDIR})"
		tar -xf "$(basename ${ORTDIR}).tgz"
		cd - &> /dev/null
	fi
	
	clang++ -O2 -std=c++14 \
	  ./onnx-mlp-standalone-src/onnx-mlp-standalone.cpp \
	  -I"${ORTDIR}/include" -L"${ORTDIR}/lib" \
	  -lonnxruntime \
	  -Wl,-rpath,@executable_path/onnx-mlp-standalone-src/onnxruntime-osx-universal2-1.19.2/lib \
	  -o ./onnx-mlp-standalone
fi

