#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

NNMODELFILE="$1"
INMOLFILE="$2"
SUBSELECETIONOFCONTACTS="$3"
LASTARG="$4"

if [ -z "$SUBSELECETIONOFCONTACTS" ]
then
	SUBSELECETIONOFCONTACTS="[]"
fi

if [ -z "$NNMODELFILE" ] || [ -z "$INMOLFILE" ] || [ -n "$LASTARG" ]
then
	echo >&2 "Error: invalid number of command-line arguments, must be exactly two - 'nn_model_file' and 'input_mol_file' [and 'subselection_of_contacts']"
	exit 1
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

if [ ! -s "${TMPLDIR}/data_vcblocks.pt" ] || [ ! -s "${TMPLDIR}/data_vcblock_ids_and_basic_values.tsv" ]
then
	echo >&2 "Error: failed to prepare input for ML"
	exit 1
fi

./run_trained_mlp_classifier.bash "$NNMODELFILE" "${TMPLDIR}/data_vcblocks.pt" > "${TMPLDIR}/predictions"

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

