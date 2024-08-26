#!/bin/bash

JOB_ID=$1
if [[ -z $JOB_ID ]]; then
    echo Usage ./script.sh START_JOB_ID
    exit 1
fi

while true; do

  # To support older jobs
  if [[ ! -d jobs/.link_$JOB_ID ]]; then

    # Skip jobs of other users
    qstat -x $JOB_ID | tail -n 1 | grep $USER > /dev/null
    if [[ $? != 0 ]]; then
      echo Skipping job ${JOB_ID}...
	    JOB_ID=$(($JOB_ID + 1))
      continue
    fi
  fi

  echo --------------------------------------------------------------
  echo $JOB_ID
  cat jobs/.link_$JOB_ID/command.txt
  echo --------------------------------------------------------------
  ./m/view_stdout.sh $JOB_ID | tail -n 14 #| head -n 6
  read
  JOB_ID=$(($JOB_ID + 1))
done
