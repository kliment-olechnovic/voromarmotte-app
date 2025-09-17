#!/bin/bash

cd "$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BUILDMODE="$1"

if [ "$BUILDMODE" == "static" ]
then
	g++ -std=c++14 -static-libgcc -static-libstdc++ -static -O3 -o "./sample-multiple-mutations" "./sample-multiple-mutations-src/sample-multiple-mutations.cpp"
else
	g++ -std=c++14 -O3 -o "./sample-multiple-mutations" "./sample-multiple-mutations-src/sample-multiple-mutations.cpp"
fi

