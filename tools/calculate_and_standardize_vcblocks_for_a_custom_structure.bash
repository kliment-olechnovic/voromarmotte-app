#!/bin/bash

cd "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INFILE="$1"
OUTPREFIX="$2"
SUBSELECETIONOFCONTACTS="$3"
LASTARG="$4"

if [ -z "$SUBSELECETIONOFCONTACTS" ]
then
	SUBSELECETIONOFCONTACTS="[]"
fi

if [ -z "$INFILE" ] || [ -z "$OUTPREFIX" ] || [ -n "$LASTARG" ]
then
	echo >&2 "Error: invalid number of command-line arguments, must be exactly two or three - 'input_file' and 'output_prefix' [and 'subselection_of_contacts']"
	exit 1
fi

if [ ! -s "$INFILE" ]
then
	echo >&2 "Error: input file '$INFILE' does not exist"
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

./voronota-js-vcblocks \
  --akbps-layered-lib "./akbps_protein_protein_config_bundle/akbps_config_bundle/akbps_layered_lib" \
  --akbps-layered-lib-weights "./akbps_protein_protein_config_bundle/akbps_config_bundle/akbps_layered_lib_weights" \
  --input "$INFILE" \
  --subselect-contacts "(([-min-seq-sep 6]) and (${SUBSELECETIONOFCONTACTS}))" \
  --output-table-file "${TMPLDIR}/raw_table" \
  --special-standardization "./training_columns_mean_and_sd_values.tsv"

if [ ! -s "${TMPLDIR}/raw_table" ]
then
	echo >&2 "Error: failed to calculate VCBlocks for '$INFILE'"
	exit 1
fi

cut -f1-9 "${TMPLDIR}/raw_table" > "${TMPLDIR}/raw_table_ids_and_basic_values"

cut -f10- "${TMPLDIR}/raw_table" > "${TMPLDIR}/standardized_table.tsv"

mkdir -p "$(dirname ${OUTPREFIX}file)"

mv "${TMPLDIR}/raw_table_ids_and_basic_values" ${OUTPREFIX}vcblock_ids_and_basic_values.tsv

mv "${TMPLDIR}/standardized_table.tsv" ${OUTPREFIX}vcblocks.tsv

