#!/bin/bash

START=$1
if [[ -z $START ]]; then
    echo Usage ./script.sh START_JOB_ID [ITERATIONS]
    exit 1
fi
END=$2
if [[ -z $END ]]; then
	  END=128
fi

echo Are you sure you want to stop all the jobs?
read
echo Running $END iterations from $START

for (( i=START; i<(START+END); i++ )); do
	  qdel $i
done
