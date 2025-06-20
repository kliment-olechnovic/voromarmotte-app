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

## Getting the latest version

The currently recommended way to obtain VoroMarmotte is cloning the VoroMarmotte git repository [https://github.com/kliment-olechnovic/voromarmotte-app](https://github.com/kliment-olechnovic/voromarmotte-app):

```bash
git clone https://github.com/kliment-olechnovic/voromarmotte-app.git
cd ./voromarmotte
```

## Building the included software

VoroMarmotte comes with a statically built 'voronota-js' binary for Linux in the 'tools' subdirectory.

The source code for 'voronota-js' is also included, and can be used to build 'voronota-js' with the following command: 

```bash
./tools/build-voronota-js.bash
```

## Setting up an environment for running VoroMarmotte

VoroMarmotte requires PyTorch, NumPy, and R.

Below is an example of setting up a suitable environment:

```bash
# install and activate Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ~/miniconda3/bin/activate

# import and activate provided environment
conda env create --file voromarmotte-env.yaml
conda activate voromarmotte-env

# if you do not have R installed in your system, install it (below is an example for Ubuntu)
sudo apt-get install r-base
```


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
    --conda-path              string     conda installation path, default is ''
    --conda-env               string     conda environment name, default is 'voromarmotte-env'
    --subselect-contacts      string     query to subselect inter-chain contacts, default is '[]'
    --output-per-contact      string     output file path for the table of per-contact scores, default is ''
    --output-table-file       string     output file path for the global scores, default is '_stdout'
    --processors              number     maximum number of processors to run in parallel, default is 1
    --help | -h                          flag to display help message and exit

Standard output:
    space-separated table of global scores

Examples:

    ./voromarmotte  --input ./model.pdb --conda-path ~/miniconda3 --conda-env 'voromarmotte-env' > ./table.txt
    
    ./voromarmotte  --input ./model.pdb --subselect-contacts '[-inter-chain]' > ./table.txt
    
    ./voromarmotte  --input ./model.pdb --output-per-contact ./table_of_contacts.txt > ./table.txt
    
    find ./models/ -type f -name '*.pdb' | ./voromarmotte --subselect-contacts '[-inter-chain]' > ./table.txt
    
```

# Output example

Running

```bash
find "./tests/input/" -type f -name '*.pdb' \
| ./voromarmotte \
  --input _list \
  --conda-path ~/miniconda3 \
  --conda-env "voromarmotte-env" \
  --processors 4 \
  --subselect-contacts '[-inter-chain]'
```

gives

```
ID          area_expected_to_persist  area_expected_to_vanish  area_total
target.pdb  736.036934416612          307.304285583388         1043.34122
model2.pdb  514.899135986745          456.753564013255         971.6527
model1.pdb  399.674485370467          572.686044629533         972.36053
```

