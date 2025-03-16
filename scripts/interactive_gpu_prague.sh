#!/bin/bash
# Launches an interactive job in Prague

$HOME/metacentrum/interactive_base.sh

qsub -q gpu -l select=1:ncpus=8:mem=32gb:ngpus=1:praha=true:scratch_shm=true -I
#:mem=16gb:scratch_local=16gb

