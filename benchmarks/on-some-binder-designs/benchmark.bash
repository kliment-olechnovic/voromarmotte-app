#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

mkdir -p "./output"

################################################################################

{
	echo "false no"
	echo "true no"
	echo "true basic"
} \
| while read -r REBUILDING RELAXING
do
	OUTFILE="./output/global_scores_rebuilt_${REBUILDING}_relaxed_${RELAXING}.txt"
	
	[ -s "$OUTFILE" ] || \
	find ./input/ -type f -name '*.pdb' \
	| ../../voromarmotte \
	  --input _list \
	  --rebuild-sidechains "$REBUILDING" \
	  --relax-with-openmm "$RELAXING" \
	  --subselect-contacts '[-a1 [-chain A]]' \
	  --output-table-file "$OUTFILE" \
	  --output-per-residue ./output/local_scores_per_residue/residues_of_INPUTNAME_mod_MODIFIED.txt \
	  --output-vscript ./output/visualizations/show_INPUTNAME_mod_MODIFIED.vs \
	  --output-pymol-vscript ./output/visualizations/show_INPUTNAME_mod_MODIFIED.py \
	  --output-atoms-file ./output/atoms/atoms_of_INPUTNAME_mod_MODIFIED.pdb \
	  --processors 4
	
	OUTFILE="./output/global_scores_interchain_rebuilt_${REBUILDING}_relaxed_${RELAXING}.txt"
	
	[ -s "$OUTFILE" ] || \
	find ./input/ -type f -name '*.pdb' \
	| ../../voromarmotte \
	  --input _list \
	  --rebuild-sidechains "$REBUILDING" \
	  --relax-with-openmm "$RELAXING" \
	  --subselect-contacts '[-inter-chain]' \
	  --output-table-file "$OUTFILE" \
	  --output-per-residue ./output/local_scores_per_residue_interchain/residues_of_INPUTNAME_mod_MODIFIED.txt \
	  --output-vscript ./output/visualizations_interchain/show_INPUTNAME_mod_MODIFIED.vs \
	  --output-pymol-vscript ./output/visualizations_interchain/show_INPUTNAME_mod_MODIFIED.py \
	  --processors 4
done

################################################################################

OUTFILE="./output/global_scores_mutated_to_every.txt"

[ -s "$OUTFILE" ] || \
find ./input/ -type f -name '*.pdb' \
| ../../voromarmotte \
  --input _list \
  --subselect-contacts '[-a1 [-chain A]]' \
  --mutate-sidechains 'interface-A-every' \
  --output-table-file "$OUTFILE" \
  --processors 30

################################################################################

