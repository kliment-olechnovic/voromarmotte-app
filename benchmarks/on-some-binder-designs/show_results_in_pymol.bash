#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "${SCRIPTDIR}/output/"

pymol-oss.pymol \
  ./atoms/atoms_of_design1_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design1_mod_rebuilt.py \
  ./suggested_mutations_to_increase_binding_stability/design1/show_design1_mutated_iface.vs.atoms.pdb \
  ./suggested_mutations_to_increase_binding_stability/design1/show_design1_mutated_iface.vs.py \
  ./atoms/atoms_of_design2_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design2_mod_rebuilt.py \
  ./suggested_mutations_to_increase_binding_stability/design2/show_design2_mutated_iface.vs.atoms.pdb \
  ./suggested_mutations_to_increase_binding_stability/design2/show_design2_mutated_iface.vs.py \
  ./atoms/atoms_of_design3_mod_rebuilt.pdb \
  ./visualizations_interchain/show_design3_mod_rebuilt.py \
  ./suggested_mutations_to_increase_binding_stability/design3/show_design3_mutated_iface.vs.atoms.pdb \
  ./suggested_mutations_to_increase_binding_stability/design3/show_design3_mutated_iface.vs.py

