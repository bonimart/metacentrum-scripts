#!/bin/bash
# Launches an interactive job anywhere in the republic

$HOME/metacentrum/interactive_base.sh

qsub -l select=1:ncpus=8:mem=32gb:scratch_shm=True -I 
#:mem=16gb:scratch_local=16gb

