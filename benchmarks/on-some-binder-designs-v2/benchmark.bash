#!/bin/bash

cd "$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mkdir -p "./output"

################################################################################

for REBUILDING in false true
do
	OUTFILE="./output/global_scores_rebuilt_${REBUILDING}.txt"
	
	[ -s "$OUTFILE" ] || \
	find ./input/ -type f -name '*.pdb' \
	| ../../voromarmotte \
	  --input _list \
	  --rebuild-sidechains "$REBUILDING" \
	  --subselect-contacts '[-a1 [-chain A]]' \
	  --output-table-file "$OUTFILE" \
	  --processors 16

	OUTDIR="./output/visualizations/rebuilt_${REBUILDING}"

	[ -d "$OUTDIR" ] || \
	find ./input/ -type f -name '*.pdb' \
	| ../../voromarmotte \
	  --input _list \
	  --rebuild-sidechains "$REBUILDING" \
	  --subselect-contacts '[-inter-chain]' \
	  --output-vscript "${OUTDIR}/show_INPUTNAME_mod_MODIFIED_iface.vs" \
	  --output-pymol-vscript "${OUTDIR}/show_INPUTNAME_mod_MODIFIED_iface.py" \
	  --output-atoms-file "${OUTDIR}/show_INPUTNAME_mod_MODIFIED_iface_atoms.pdb" \
	  --processors 16 \
	> /dev/null
done

################################################################################

find ./input/ -type f -name '*.pdb' \
| while read -r STRUCTFILE
do
	STRUCTNAME="$(basename ${STRUCTFILE} .pdb)"
	OUTDIR="./output/suggested_mutations_to_increase_binding_stability/${STRUCTNAME}"
	
	mkdir -p "$OUTDIR"
	
	MUTATIONSCORESFILE="${OUTDIR}/global_scores_of_mutations.txt"
	
	[ -s "$MUTATIONSCORESFILE" ] || \
	../../voromarmotte \
	  --input "$STRUCTFILE" \
	  --subselect-contacts '[-a1 [-chain A]]' \
	  --mutate-sidechains stabilize-interface-A-1000-8 \
	  --output-table-file "$MUTATIONSCORESFILE" \
	  --processors 16

	VISFILE="${OUTDIR}/show_${STRUCTNAME}_mutated_iface"
	
	[ -s "${VISFILE}.vs" ] || \
	../../voromarmotte \
	  --input "$STRUCTFILE" \
	  --mutate-sidechains "$(cat ${MUTATIONSCORESFILE} | awk '{if(NR==2){print $2}}' | sed 's/^rebuilt_mutated_//' )" \
	  --subselect-contacts '[-inter-chain]' \
	  --output-vscript "${VISFILE}.vs" \
	  --output-pymol-vscript "${VISFILE}.py" \
	  --output-atoms-file "${VISFILE}_atoms.pdb" \
	> /dev/null
done

################################################################################

find ./input/ -type f -name '*.pdb' \
| while read -r STRUCTFILE
do
	STRUCTNAME="$(basename ${STRUCTFILE} .pdb)"
	OUTDIR="./output/suggested_mutations_to_decrease_binding_stability/${STRUCTNAME}"
	MUTATIONSCORESFILE="${OUTDIR}/global_scores_of_mutations.txt"
	
	[ -s "$MUTATIONSCORESFILE" ] || \
	../../voromarmotte \
	  --input "$STRUCTFILE" \
	  --subselect-contacts '[-a1 [-chain A]]' \
	  --mutate-sidechains destabilize-interface-A-100-2 \
	  --output-table-file "$MUTATIONSCORESFILE" \
	  --processors 16
done

################################################################################

