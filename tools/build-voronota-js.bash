#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

g++ -std=c++14 -I"./voronota-js-src/expansion_js/src/dependencies" -O3 -o "./voronota-js" $(find ./voronota-js-src/ -name '*.cpp')
