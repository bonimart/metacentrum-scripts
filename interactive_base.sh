#!/bin/bash

echo --------------------------------------------------------------------------
echo Quick copy \& paste commands:
echo --------------------------------------------------------------------------

echo module add python/python-3.10.4-intel-19.0.4-sc7snnf
echo export TMPDIR=\$SCRATCHDIR/tmp\; mkdir \$TMPDIR
echo
echo pwd
echo ln -s $HOME/labs labs
echo ln -s $HOME/venv venv
echo tar -x -I pigz --checkpoint=10000 -f $HOME/venv.tar.gz
echo "export PATH=\$(pwd)/venv/bin:\$PATH"
echo
echo --------------------------------------------------------------------------
