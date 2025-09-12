#!/bin/bash

cd "$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BUILDMODE="$1"

./build-voronota-lt.bash "$BUILDMODE"

./build-voronota-js.bash "$BUILDMODE"

./build-r-alternative.bash "$BUILDMODE"

./build-onnx-mlp-standalone.bash "$BUILDMODE"

