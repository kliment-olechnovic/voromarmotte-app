#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

MODELFILE="$1"
OUTPUTFILE="$2"

if [ -z "$MODELFILE" ] || [ ! -s "$MODELFILE" ]
then
	echo >&2 "Invalid model file '${MODELFILE}'."
	exit 1
fi

if [ -z "$OUTPUTFILE" ]
then
	echo >&2 "Invalid output file '${OUTPUTFILE}'."
	exit 1
fi

ARGSFILE="${MODELFILE}.args.txt"

if [ ! -s "$ARGSFILE" ]
then
	echo >&2 "Invalid parameters file '${ARGSFILE}'."
	exit 1
fi

export PYTHONDONTWRITEBYTECODE="yes"

mkdir -p "$(dirname ${OUTPUTFILE})"

python convert_trained_mlp_classifier_to_onnx.py --model-file "$MODELFILE" --onnx-file "$OUTPUTFILE" $(cat ${ARGSFILE})

