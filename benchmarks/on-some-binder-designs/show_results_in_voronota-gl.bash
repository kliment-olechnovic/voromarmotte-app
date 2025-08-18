#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "${SCRIPTDIR}/output/"

voronota-gl \
  ./atoms/atoms_of_design1_mod_no.pdb \
  ./visualizations_interchain/show_design1_mod_no.vs \
  ./atoms/atoms_of_design1_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design1_mod_rebuilt.vs \
  ./atoms/atoms_of_design2_mod_no.pdb \
  ./visualizations_interchain/show_design2_mod_no.vs \
  ./atoms/atoms_of_design2_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design2_mod_rebuilt.vs \
  ./atoms/atoms_of_design3_mod_no.pdb \
  ./visualizations_interchain/show_design3_mod_no.vs \
  ./atoms/atoms_of_design3_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design3_mod_rebuilt.vs

