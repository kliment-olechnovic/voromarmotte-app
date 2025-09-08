#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

MODELFILE="$1"
DATAFILE="$2"

if [ -z "$MODELFILE" ] || [ ! -s "$MODELFILE" ]
then
	echo >&2 "Invalid model file '${MODELFILE}'."
	exit 1
fi

if [ -z "$DATAFILE" ] || [ ! -s "$DATAFILE" ]
then
	echo >&2 "Invalid data file '${DATAFILE}'."
	exit 1
fi

export PYTHONDONTWRITEBYTECODE="yes"

python run_trained_mlp_classifier_using_onnx.py --onnx-file "$MODELFILE" --data-file "$DATAFILE"

