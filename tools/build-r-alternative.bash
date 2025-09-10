#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BUILDMODE="$1"

if [ "$BUILDMODE" == "static" ]
then
	g++ -std=c++14 -static-libgcc -static-libstdc++ -static -O3 -o "./r-alternative" "./r-alternative-src/r-alternative.cpp"
else
	g++ -std=c++14 -O3 -o "./r-alternative" "./r-alternative-src/r-alternative.cpp"
fi

