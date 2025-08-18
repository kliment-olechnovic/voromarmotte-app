#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "${SCRIPTDIR}/output/"

pymol-oss.pymol \
  ./atoms/atoms_of_design1_mod_no.pdb \
  ./visualizations_interchain/show_design1_mod_no.py \
  ./atoms/atoms_of_design1_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design1_mod_rebuilt.py \
  ./atoms/atoms_of_design2_mod_no.pdb \
  ./visualizations_interchain/show_design2_mod_no.py \
  ./atoms/atoms_of_design2_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design2_mod_rebuilt.py \
  ./atoms/atoms_of_design3_mod_no.pdb \
  ./visualizations_interchain/show_design3_mod_no.py \
  ./atoms/atoms_of_design3_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design3_mod_rebuilt.py

