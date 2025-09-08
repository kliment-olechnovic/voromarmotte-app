# About VoroMarmotte

VoroMarmotte is method to predict whether Voronoi tessellation-derived contact areas
observed in a single conformation of a protein are likely to persist (remain stable) or not persist (decrease in area)
in an ensemble of multiple conformations of the same protein.
In other words, VoroMarmotte predicts contact area heterogeneity from a single input structure.

VoroMarmotte is developed as one of the results of the MARMOTTTE project.
The details of the method are to be published soon.
This repository provides an alpha version of VoroMarmotte app.

VoroMarmotte is developed by Kliment Olechnovic ([www.kliment.lt](https://www.kliment.lt)).

# Obtaining and setting up VoroMarmotte

## System requirements

To use the default fast inference engine, Linux x64 is required, R is required, but conda (Anaconda or Miniconda) is not required.

Other inference engines can be used on any system with conda (Anaconda or Miniconda).

## Getting the latest version

The recommended way to obtain VoroMarmotte is cloning the VoroMarmotte git repository [https://github.com/kliment-olechnovic/voromarmotte-app](https://github.com/kliment-olechnovic/voromarmotte-app):

```bash
git clone https://github.com/kliment-olechnovic/voromarmotte-app.git
cd ./voromarmotte-app
```

## Building the included software

To use the default fast inference engine, the needed executables must be rebuilt - for example, with the following single command: 

```bash
./tools/build-all.bash
```

Other inference engines can work with the included statically built executables.

## Setting up an environment for running VoroMarmotte

For some optional features (using non-default inference engines, running relaxation using OpenMM)
VoroMarmotte may nee to operate inside a suitable conda environment.

Below is an example of setting up a suitable environment:

```bash
# install and activate Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ~/miniconda3/bin/activate

# import and activate provided environment
conda env create --file ./tools/env/voromarmotte-env.yaml
conda activate voromarmotte-env
```

More information about creatin/loading/removing the `voromarmotte-env` environment is available [here](./tools/env/voromarmotte-env-info.md).

# Running the VoroMarmotte command-line tool

The overview of command-line options, as well as input and output, is printed when running the "voromarmotte" executable with "--help" or "-h" flags:

```bash
voromarmotte --help

voromarmotte -h
```

The following is the help message output:

```

'voromarmotte' predicts persistence of contact areas in a protein structure

Options:
    --input | -i              string  *  input file path or '_list' to read file paths from stdin
    --inference-engine        string     MLP inference engine to use, can be 'onnx-mlp-standalone' (default) or 'onnx' or 'pytorch'
    --rebuild-sidechains      string     flag to rebuild side-chains with FASPR, can be 'false' or 'true', default is 'false'
    --mutate-sidechains       string     triples of strings (chain resnum resname) to define mutations and rebuild with FASPR
    --relax-with-openmm       string     parameters (':'-separated tokens, or 'basic') to enable the OpenMM relaxation, default is ''
    --subselect-contacts      string     query to subselect inter-chain contacts, default is '[]'
    --output-atoms-file       string     output file path for the processed input atoms
    --output-per-contact      string     output file path for the table of per-contact scores, default is ''
    --output-per-residue      string     output file path for the table of per-residue summary scores, default is ''
    --output-table-file       string     output file path for the global scores, default is '_stdout'
    --output-vscript          string     output file path for the visualization script for Voronota-GL
    --output-pymol-vscript    string     output file path for the visualization script for PyMol
    --processors              number     maximum number of processors to run in parallel, default is 1
    --help | -h                          flag to display help message and exit

Standard output:
    space-separated table of global scores

Examples:

    ./voromarmotte  --input ./model.pdb > ./table.txt
    
    ./voromarmotte  --input ./model.pdb --subselect-contacts '[-inter-chain]' > ./table.txt
    
    ./voromarmotte  --input ./model.pdb --subselect-contacts '[-a1 [-chain A]]' --output-per-contact ./table_of_contacts.txt > ./table.txt
    
    find ./models/ -type f -name '*.pdb' | ./voromarmotte --input _list --subselect-contacts '[-inter-chain]' > ./table.txt

```

# Output example

Running

```bash
find "./tests/input/" -type f -name '*.pdb' \
| ./voromarmotte \
  --input _list \
  --processors 4
```

gives

```
ID          modified  pseudoenergy       area        best_core_pseudoenergy  best_core_area  ic_fraction        ic_area_pseudoenergy  ic_area_total  ic_best_core_pseudoenergy  ic_best_core_area
target.pdb  no        -12702.6357847878  8719.37648  -13048.3470685256       7978.57775      0.11965777855712   -1330.24342400865     1043.34122     -1465.41011491134          963.03436
model2.pdb  no        4095.2596881042    8176.68624  -105.657960563974       1408.45828      0.118832088144304  -192.572275218319     971.6527       -478.75702606988           732.5084
model1.pdb  no        6819.02637251657   8778.85413  156.928428500962        1775.00483      0.110761668390998  571.996620780361      972.36053      -17.1168634440248          721.16258
```

# Visualization example

Running

```bash
./voromarmotte \
  --input "./tests/input/set1/target.pdb" \
  --subselect-contacts "[-inter-chain]" \
  --output-vscript "show_inter_chain_interface.vs" \
  --output-pymol-vscript "show_inter_chain_interface.py"
```

output scores and generates two visualiztion scripts: "show_inter_chain_interface.vs" and "show_inter_chain_interface.py" for PyMol.

The "show_interface.vs" script is to be run by Voronota-GL after loading the input structure:

```bash
voronota-gl "./tests/input/set1/target.pdb" "show_inter_chain_interface.vs"
```

![](./docs/screenshot-voronota-gl.png)

The "show_interface.py" script is to be run by PyMol (should work with both 'pymol' and 'pymol-oss.pymol'):

```bash
pymol "./tests/input/set1/target.pdb" "show_inter_chain_interface.py"
```

![](./docs/screenshot-pymol.png)

# Analyzing and improving binders

Plese see [this page](./benchmarks/on-some-binder-designs/ABOUT.md) that describes possible usages of VoroMarmotte for analyzing and improving protein binder designs.
