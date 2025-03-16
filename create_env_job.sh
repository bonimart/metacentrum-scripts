#!/bin/bash
#PBS -N create_env
##PBS -q gpu
#PBS -l select=1:ncpus=8:mem=32gb:scratch_shm=true
#:ngpus=1:gpu_mem=8gb
#
# Creates a virtual environment in the venv dir in your home dir in praha1
# Currently not working well (at all), fails with quota exceptions

# Working solution for the interactive mode
# ./interactive_fast.sh
# export TMPDIR=$SCRATCHDIR
# module add python/python-3.10.4-intel-19.0.4-sc7snnf
# python3 -m venv venv
# venv/bin/pip install --no-cache-dir --upgrade pip setuptools
# venv/bin/pip install --no-cache-dir keras~=3.0.5 --extra-index-url=https://download.pytorch.org/whl/cu118 torch~=2.2.0 torchaudio~=2.2.0 torchvision~=0.17.0 torchmetrics~=1.3.1 flashlight-text~=0.0.3 tensorboard~=2.16.2 transformers~=4.37.2 gymnasium~=1.0.0a1 pygame~=2.5.2
# tar -I pigz -cf venv.tar.gz venv
# mv venv.tar.gz /storage/LOCATION/home/USER
#
# Move the venv to the storage of your choice

# For debugging
# set -x

# substitute username and path to to your real username and path
DATADIR=/storage/praha1/home/${USER}
VENV_DIR=.venv
echo DATADIR    = $DATADIR
echo SCRATCHDIR = $SCRATCHDIR
echo VENV_DIR   = $VENV_DIR

# Make temp dir in the SCRATCHDIR to prevent quota problems
export TMPDIR=$SCRATCHDIR/tmp
mkdir $TMPDIR

trap 'clean_scratch' TERM EXIT

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of node it is run on and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

module add python/3.11.11-gcc-10.2.1-555dlyc

# test if scratch directory is set
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# move into scratch directory
cd $SCRATCHDIR

# echo Getting the setup script
# cp $DATADIR/setup_env.sh $SCRATCHDIR || { echo >&2 "Error while copying input file(s)!"; exit 2; }

echo Setting up
# Not working as python is not accessible inside the script
# chmod +x ./setup_env.sh
# export VENV_DIR
# ./setup_env.sh <<< "c11" || { echo >&2 "Calculation ended up erroneously (with a code $?) !!"; exit 3; }

# also update ./../setup_env.sh
FLAVOUR=cu118
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating venv in $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python3" -m ensurepip
"$VENV_DIR/bin/python3" -m pip install --no-cache-dir --extra-index-url=https://download.pytorch.org/whl/$FLAVOUR npfl139

ls -a

echo Compressing the $VENV_DIR
tar -I pigz -cf $VENV_DIR.tar.gz $VENV_DIR

echo Uploading the venv
mv $VENV_DIR.tar.gz $DATADIR/ || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }

echo Done

# clean the SCRATCH directory
clean_scratch
