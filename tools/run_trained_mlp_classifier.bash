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

ARGSFILE="${MODELFILE}.args.txt"

if [ ! -s "$ARGSFILE" ]
then
	echo >&2 "Invalid parameters file '${ARGSFILE}'."
	exit 1
fi

python -B run_trained_mlp_classifier.py --model-file "$MODELFILE" --data-file "$DATAFILE" $(cat ${ARGSFILE})

