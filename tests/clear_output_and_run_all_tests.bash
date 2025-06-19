#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPTDIR"

rm -rf "./output"
mkdir -p "./output"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte-app \
  --input _list \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --processors 4 \
> "./output/all_global_scores_for_all_contacts.txt"

find "./input/" -type f -name '*.pdb' \
| ../voromarmotte-app \
  --input _list \
  --conda-path "${HOME}/miniconda3" \
  --conda-env "voromarmotte-env" \
  --processors 4 \
  --subselect-contacts '[-inter-chain]' \
> "./output/all_global_scores_for_inter_chain_contacts.txt"

find "./input/" -type f -name '*.pdb' \
| while read -r INFILE
do
	INPUTNAME="$(basename ${INFILE} .pdb)"
	
	../voromarmotte-app \
	  --input "$INFILE" \
	  --conda-path "${HOME}/miniconda3" \
	  --conda-env "voromarmotte-env" \
	  --processors 4 \
	  --subselect-contacts '[-inter-chain]' \
	  --output-per-contact "./output/local_scores_for_inter_chain_contacts_of_${INPUTNAME}.txt" \
	  --output-table-file "./output/global_scores_for_inter_chain_contacts_of_${INPUTNAME}.txt"
done

find "./output/" -type f -name '*global_scores*' \
| sort \
| while read -r RESULTFILE
do
	echo "$RESULTFILE"
	cat "$RESULTFILE" | sed 's/^/    /'
	echo
done

