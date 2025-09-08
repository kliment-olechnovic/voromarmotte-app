#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INFERENCE_ENGINE="$1"
NNMODELFILE="$2"
INMOLFILE="$3"
SUBSELECETIONOFCONTACTS="$4"
LASTARG="$5"

if [ -z "$SUBSELECETIONOFCONTACTS" ]
then
	SUBSELECETIONOFCONTACTS="[]"
fi

if [ -z "$INFERENCE_ENGINE" ] || [ -z "$NNMODELFILE" ] || [ -z "$INMOLFILE" ] || [ -n "$LASTARG" ]
then
	echo >&2 "Error: invalid number of command-line arguments"
	exit 1
fi

if [ "$INFERENCE_ENGINE" != "onnx-mlp-standalone" ] && [ "$INFERENCE_ENGINE" != "onnx" ] && [ "$INFERENCE_ENGINE" != "pytorch" ]
then
	echo >&2 "Error: invalid value for the inference engine name"
	exit 1
fi

if [ "$INFERENCE_ENGINE" == "onnx-mlp-standalone" ] || [ "$INFERENCE_ENGINE" == "onnx" ]
then
	NNMODELFILE="${NNMODELFILE}.onnx"
fi

if [ ! -s "$NNMODELFILE" ]
then
	echo >&2 "Error: input NN model file '$NNMODELFILE' does not exist"
	exit 1
fi

if [ ! -s "$INMOLFILE" ]
then
	echo >&2 "Error: input molecular structure file '$INMOLFILE' does not exist"
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

./calculate_and_standardize_vcblocks_for_a_custom_structure.bash "$INMOLFILE" "${TMPLDIR}/data_" "$SUBSELECETIONOFCONTACTS"

if [ ! -s "${TMPLDIR}/data_vcblocks.bin" ] || [ ! -s "${TMPLDIR}/data_vcblock_ids_and_basic_values.tsv" ]
then
	echo >&2 "Error: failed to prepare input for ML"
	exit 1
fi

INFERENCE_SCRIPT="./run_trained_mlp_classifier_using_$(echo ${INFERENCE_ENGINE} | tr '-' '_').bash"

$INFERENCE_SCRIPT "$NNMODELFILE" "${TMPLDIR}/data_vcblocks.bin" > "${TMPLDIR}/predictions"

if [ ! -s "${TMPLDIR}/predictions" ]
then
	echo >&2 "Error: failed run ML inference"
	exit 1
fi

paste "${TMPLDIR}/data_vcblock_ids_and_basic_values.tsv" "${TMPLDIR}/predictions" | sed 's/\s\+/\t/g' > "${TMPLDIR}/named_predictions"

if [ ! -s "${TMPLDIR}/named_predictions" ]
then
	echo >&2 "Error: failed to compile named predictions"
	exit 1
fi

cat "${TMPLDIR}/named_predictions"

