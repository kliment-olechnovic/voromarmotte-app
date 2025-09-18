#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "${SCRIPTDIR}/output/"

pymol \
  ./visualizations/rebuilt_true/show_design1_mod_rebuilt_iface_atoms.pdb \
  ./visualizations/rebuilt_true/show_design1_mod_rebuilt_iface.py \
  ./suggested_mutations_to_increase_binding_stability/design1/show_design1_mutated_iface_atoms.pdb \
  ./suggested_mutations_to_increase_binding_stability/design1/show_design1_mutated_iface.py \
  ./visualizations/rebuilt_true/show_design2_mod_rebuilt_iface_atoms.pdb \
  ./visualizations/rebuilt_true/show_design2_mod_rebuilt_iface.py \
  ./suggested_mutations_to_increase_binding_stability/design2/show_design2_mutated_iface_atoms.pdb \
  ./suggested_mutations_to_increase_binding_stability/design2/show_design2_mutated_iface.py \
  ./visualizations/rebuilt_true/show_design3_mod_rebuilt_iface_atoms.pdb \
  ./visualizations/rebuilt_true/show_design3_mod_rebuilt_iface.py \
  ./suggested_mutations_to_increase_binding_stability/design3/show_design3_mutated_iface_atoms.pdb \
  ./suggested_mutations_to_increase_binding_stability/design3/show_design3_mutated_iface.py

