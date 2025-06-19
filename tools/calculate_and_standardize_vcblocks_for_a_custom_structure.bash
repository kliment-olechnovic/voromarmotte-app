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
  --akbps-layered-lib ./akbps_protein_protein_config_bundle.tar.gz \
  --input "$INFILE" \
  --subselect-contacts "(([-min-seq-sep 6]) and (${SUBSELECETIONOFCONTACTS}))" \
  --output-table-file "${TMPLDIR}/raw_table"

if [ ! -s "${TMPLDIR}/raw_table" ]
then
	echo >&2 "Error: failed to calculate VCBlocks for '$INFILE'"
	exit 1
fi

R --vanilla --args "./training_columns_mean_and_sd_values.tsv" "${TMPLDIR}/raw_table" "${TMPLDIR}/standardized_table.tsv" << 'EOF' > /dev/null
args=commandArgs(TRUE);
input_stats=args[1];
input_table=args[2];
output_table=args[3];
stats=read.table(input_stats, header=TRUE, stringsAsFactors=FALSE);
df=read.table(input_table, header=TRUE, stringsAsFactors=FALSE);
df=df[which(df$main_rr_contact__area>1.0),];
write.table(df, file=input_table, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");
write.table(df[,c("ID", "chain1", "seqnum1", "resname1", "chain2", "seqnum2", "resname2")], file=paste0(input_table, "_ids"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");
write.table(df[,c("ID", "chain1", "seqnum1", "resname1", "chain2", "seqnum2", "resname2", "main_rr_contact__area", "main_rr_contact__boundary")], file=paste0(input_table, "_ids_and_basic_values"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");
df$persistence=0.0;
df=df[,colnames(stats)];
for(i in 2:ncol(df))
{
	df[,i]=(df[,i]-stats[1, i])/stats[2, i];
}
write.table(df, file=output_table, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t");
EOF

if [ ! -s "${TMPLDIR}/standardized_table.tsv" ]
then
	echo >&2 "Error: failed to standardize VCBlocks for '$INFILE'"
	exit 1
fi

python3 - << EOF
import numpy as np
import torch
data = np.loadtxt("${TMPLDIR}/standardized_table.tsv", delimiter="\t", dtype=np.float32, skiprows=1)
tensor = torch.from_numpy(data)
torch.save(tensor, "${TMPLDIR}/standardized_table.pt")
EOF

if [ ! -s "${TMPLDIR}/standardized_table.pt" ]
then
	echo >&2 "Error: failed to generate PyTorch data file for '$INFILE'"
	exit 1
fi

mkdir -p "$(dirname ${OUTPREFIX}file)"

mv "${TMPLDIR}/raw_table" ${OUTPREFIX}vcblocks_raw.tsv

mv "${TMPLDIR}/raw_table_ids" ${OUTPREFIX}vcblock_ids.tsv

mv "${TMPLDIR}/raw_table_ids_and_basic_values" ${OUTPREFIX}vcblock_ids_and_basic_values.tsv

mv "${TMPLDIR}/standardized_table.pt" ${OUTPREFIX}vcblocks.pt

