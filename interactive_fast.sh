#!/bin/bash
# Launches an interactive job anywhere in the republic

$HOME/metacentrum/interactive_base.sh

qsub -q gpu -l select=1:ncpus=8:mem=32gb:ngpus=1:scratch_shm=true -I 
#:mem=16gb:ngpus=1:scratch_local=16gb

