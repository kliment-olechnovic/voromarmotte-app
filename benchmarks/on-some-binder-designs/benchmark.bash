#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

mkdir -p "./output"

################################################################################

{
	echo "false no"
	echo "true no"
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
	  --processors 16
	
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
	  --processors 16
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
  --processors 16

################################################################################

find ./input/ -type f -name '*.pdb' \
| while read -r STRUCTFILE
do
	STRUCTNAME="$(basename ${STRUCTFILE} .pdb)"
	OUTDIR="./output/suggested_mutations_to_increase_binding_stability/${STRUCTNAME}"
	
	mkdir -p "$OUTDIR"
	
	cat "./output/global_scores_mutated_to_every.txt" \
	| awk -v id=$(basename ${STRUCTFILE}) '{if($1=="ID" || ($1==id && $2=="rebuilt")){print $0}}' \
	> "${OUTDIR}/global_scores_nonmutated.txt"
	
	cat "./output/global_scores_mutated_to_every.txt" \
	| awk -v id=$(basename ${STRUCTFILE}) '{if($1=="ID" || ($1==id && $2!="rebuilt")){print $0}}' \
	> "${OUTDIR}/global_scores_mutated_single.txt"
	
	REQUESTSFILE="${OUTDIR}/multiple_mutation_requests.txt"
	
	[ -s "$REQUESTSFILE" ] || \
	./suggest-mutations-to-increase-binding-stability \
	  --input-table "./output/global_scores_mutated_to_every.txt" \
	  --file-id "${STRUCTFILE}" \
	  --output-dir "${OUTDIR}"
	
	MUTATIONSCORESFILE="${OUTDIR}/global_scores_mutated_multiple.txt"
	
	[ -s "$MUTATIONSCORESFILE" ] || \
	cat "$REQUESTSFILE" \
	| ../../voromarmotte \
	  --input _list \
	  --mutate-sidechains '_list' \
	  --subselect-contacts '[-a1 [-chain A]]' \
	  --output-table-file "$MUTATIONSCORESFILE" \
	  --processors 16
	
	VISFILE="${OUTDIR}/show_${STRUCTNAME}_mutated_iface.vs"
	
	[ -s "$VISFILE" ] || \
	../../voromarmotte \
	  --input "$STRUCTFILE" \
	  --mutate-sidechains "$(cat ${MUTATIONSCORESFILE} | awk '{if(NR==2){print $2}}' | sed 's/^rebuilt_mutated_//' )" \
	  --subselect-contacts '[-inter-chain]' \
	  --output-vscript "$VISFILE" \
	  --output-pymol-vscript "${VISFILE}.py" \
	  --output-atoms-file "${VISFILE}.atoms.pdb" \
	> "${VISFILE}.scores.txt"
done

################################################################################



