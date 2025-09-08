#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

./build-voronota-lt.bash "$1"

./build-voronota-js.bash "$1"

./tools/build-onnx-mlp-standalone.bash

