#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

mkdir -p "./output"

################################################################################

OUTFILE="./output/global_scores_inter_chain.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

OUTFILE="./output/global_scores_inter_chain_rebuilt.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --rebuild-sidechains true \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

OUTFILE="./output/global_scores_inter_chain_rebuilt_relaxed.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --rebuild-sidechains true \
  --relax-with-openmm basic \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

OUTFILE="./output/global_scores_inter_chain_mutated_to_ALA.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --mutate-sidechains 'interface-A-ALA' \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

OUTFILE="./output/global_scores_inter_chain_mutated_to_ALA_and_relaxed.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --mutate-sidechains 'interface-A-ALA' \
  --relax-with-openmm basic \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

OUTFILE="./output/global_scores_inter_chain_mutated_to_every.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --mutate-sidechains 'interface-A-every' \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

OUTFILE="./output/global_scores_inter_chain_mutated_to_every_and_relaxed.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-inter-chain]' \
  --mutate-sidechains 'interface-A-every' \
  --relax-with-openmm basic \
  --output-table-file "$OUTFILE" \
  --processors 20 \

################################################################################

