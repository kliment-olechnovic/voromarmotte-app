# Commands to set up the 'voromarmotte-env' environment:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh

source ~/miniconda3/bin/activate

conda config --add channels conda-forge

conda config --set channel_priority strict

conda create -n voromarmotte-env

conda activate voromarmotte-env

conda install pip

pip3 install torch --index-url https://download.pytorch.org/whl/cpu

conda install numpy pandas openmm pdbfixer r-base

conda env export -n voromarmotte-env --no-builds > voromarmotte-env.yaml
```

## Troubleshooting 'voromarmotte-env.yaml'

You may want to remove `+` postfixes if `pip` gets confused.
For examle, replace `torch==2.8.0+cu126` with `torch==2.8.0`.


# Commands to load the 'voromarmotte-env' environment:

```bash
conda env create --file ./env/voromarmotte-env.yaml

conda activate voromarmotte-env
```

# Commands used to remove the 'voromarmotte-env' environment:

```bash
conda deactivate

conda env list

conda env remove -n voromarmotte-env

conda env list
```

