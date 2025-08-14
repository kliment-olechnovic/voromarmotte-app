#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

rm -rf "./output"
mkdir -p "./output"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte \
  --input _list \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --processors 4 \
> "./output/all_global_scores_for_all_contacts.txt"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte \
  --input _list \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --processors 4 \
  --subselect-contacts '[-inter-chain]' \
> "./output/all_global_scores_for_inter_chain_contacts.txt"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte \
  --input _list \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --processors 4 \
  --subselect-contacts '[-inter-chain]' \
  --rebuild-sidechains true \
> "./output/all_global_scores_for_rebuilt_inter_chain_contacts.txt"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte \
  --input _list \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --processors 4 \
  --subselect-contacts '[-inter-chain]' \
  --rebuild-sidechains true \
  --mutate-sidechains 'any 55 GLY' \
> "./output/all_global_scores_for_rebuilt_mutated_inter_chain_contacts.txt"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte \
  --input _list \
  --processors 4 \
  --subselect-contacts '[-inter-chain]' \
  --output-per-contact "./output/local_scores_for_inter_chain_contacts_of_INPUTNAME.txt" \
  --output-vscript "./output/show_inter_chain_contacts_of_INPUTNAME.vs" \
  --output-pymol-vscript "./output/show_inter_chain_contacts_of_INPUTNAME.py" \
  --output-per-residue "./output/local_scores_per_residue_for_inter_chain_contacts_of_INPUTNAME.txt" \
  --output-table-file "./output/all_global_scores_for_inter_chain_contacts_run2.txt"
  
find "./input/" -type f -name '*.pdb' \
| ../voromarmotte \
  --input _list \
  --processors 4 \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --subselect-contacts '[]' \
  --rebuild-sidechains true \
  --output-per-contact "./output/local_scores_for_all_contacts_of_INPUTNAME.txt" \
  --output-per-residue "./output/local_scores_per_residue_for_all_contacts_of_INPUTNAME.txt" \
> /dev/null

find "./input/" -type f -name '*.pdb' \
| while read -r INFILE
do
	INPUTNAME="$(basename ${INFILE} .pdb)"

	{
cat << EOF
${INFILE} A 48 ALA
${INFILE} A 48 LEU
${INFILE} A 48 GLY
${INFILE} A 48 PHE
${INFILE} A 48 TRP
${INFILE} A 48 ARG
${INFILE} A 48 CYS
EOF
	} \
	| ../voromarmotte \
	  --input _list \
	  --mutate-sidechains _list \
	  --conda-path "${HOME}/miniconda3" \
	  --subselect-contacts '[-inter-chain]' \
	  --processors 4 \
	  --output-table-file "./output/global_scores_for_inter_chain_contacts_of_mutated_${INPUTNAME}.txt"

	../voromarmotte \
	  --input "$INFILE" \
	  --processors 4 \
	  --subselect-contacts '[-inter-chain]' \
	  --mutate-sidechains 'A 48 every' \
	  --output-table-file "./output/global_scores_for_inter_chain_contacts_of_exhaustively_mutated_${INPUTNAME}.txt"
done


find "./output/" -type f -name '*scores*' | xargs -L 1 ./reprint_table_with_less_digits.bash

find "./output/" -type f -name '*global_scores*' \
| sort \
| while read -r RESULTFILE
do
	echo "$RESULTFILE"
	cat "$RESULTFILE" | sed 's/^/    /'
	echo
done

