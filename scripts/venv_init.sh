#!/bin/bash
#PBS -N venv_init
#PBS -l select=1:ncpus=1:mem=8gb:scratch_local=10gb
# Creates a virtual environment in the scratch directory
# and moves it to the home directory in .tar.gz format

# substitute username and path to to your real username and path
DATADIR=/storage/praha1/home/${USER}
VENV_DIR=.venv

echo DATADIR    = $DATADIR
echo SCRATCHDIR = $SCRATCHDIR
echo VENV_DIR   = $VENV_DIR

# https://ufal.mff.cuni.cz/courses/npfl139/2425-summer#faq_metacentrum
export TMPDIR=$SCRATCHDIR
trap 'clean_scratch' TERM EXIT
module add python/3.11.11-gcc-10.2.1-555dlyc

# move into scratch directory
cd $SCRATCHDIR

echo Setting up virtual environment
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating venv in $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi
echo Virtual environment created

echo Installing dependencies
TORCH_FLAVOR=cu118
"$VENV_DIR/bin/python3" -m ensurepip
"$VENV_DIR/bin/python3" -m pip install --no-cache-dir --extra-index-url=https://download.pytorch.org/whl/$TORCH_FLAVOR npfl139 npfl138

ls -a

echo Compressing $VENV_DIR
tar -I pigz -cf $VENV_DIR.tar.gz $VENV_DIR

echo Uploading the virtual environment to $DATADIR
mv $VENV_DIR.tar.gz $DATADIR/ || { echo >&2 "Result file(s) copying failed (with code $?)"; exit 1; }

echo Done
