# About VoroMarmotte

VoroMarmotte is method to predict whether Voronoi tessellation-derived contact areas
observed in a single conformation of a protein are likely to persist (remain stable) or not persist (decrease in area)
in an ensemble of multiple conformations of the same protein.
In other words, VoroMarmotte predicts contact area heterogeneity from a single input structure.

VoroMarmotte is developed as one of the results of the MARMOTTTE project.
The details of the method are to be published soon.
This repository provides an alpha version of VoroMarmotte app.

VoroMarmotte is developed by Kliment Olechnovic ([www.kliment.lt](https://www.kliment.lt)).

# Quick start

The recommended way to obtain VoroMarmotte is cloning the VoroMarmotte git repository [https://github.com/kliment-olechnovic/voromarmotte-app](https://github.com/kliment-olechnovic/voromarmotte-app):

```bash
git clone https://github.com/kliment-olechnovic/voromarmotte-app.git
```

Then change to the "voromarmotte-app" directory:

```bash
cd ./voromarmotte-app
```

Then build the needed executables using the following single command:

```bash
./tools/build-all.bash
```

Then run the VoroMarmotte application:

```bash
find "./tests/input/" -type f -name '*.pdb' | ./voromarmotte --input _list --processors 4
```

## Even quicker start

On Linux, running './tools/build-all.bash' is most often not required because the VoroMarmotte repository includes executables statically built for Linux x64.

Thus, to get and try VoroMarmotte on Linux, just run the following commands:

```bash
git clone https://github.com/kliment-olechnovic/voromarmotte-app.git

cd ./voromarmotte-app

find "./tests/input/" -type f -name '*.pdb' | ./voromarmotte --input _list --processors 4
```

## System requirements

To use the default fast inference engine, Linux x64 or macOS operating system is required.

The software was developed and tested on Linux x64, it has not yet been tested on macOS or WSL (Windows Subsystem for Linux).

## Optional additional environment setup

For some optional features (using non-default inference engines, running relaxation using OpenMM)
VoroMarmotte may need to operate inside a suitable conda environment.

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
ID          modified  pseudoenergy            area                  best_core_pseudoenergy  best_core_area        ic_fraction        ic_area_pseudoenergy   ic_area_total         ic_best_core_pseudoenergy  ic_best_core_area
target.pdb  no        -12702.635784787828015  8719.376479999993535  -13048.347068525612485  7978.577749999996740  0.119657778557120  -1330.243424008653392  1043.341220000000021  -1465.410114911339861      963.034359999999992
model2.pdb  no        4095.259688104204997    8176.686239999999998  -105.657960563974797    1408.458280000000059  0.118832088144304  -192.572275218318993   971.652699999999754   -478.757026069879771       732.508399999999824
model1.pdb  no        6819.026372516565971    8778.854130000005171  156.928428500961758     1775.004829999999174  0.110761668390998  571.996620780361241    972.360530000000040   -17.116863444024744        721.162580000000048
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
