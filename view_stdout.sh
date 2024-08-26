#!/bin/bash

ID=$1
ID=$(echo $ID | cut -d ':' -f1)

TYPE=$2
case "$TYPE" in
    "out" ) TYPE=out ;;
    "stdout" ) TYPE=out ;;
    "" ) TYPE=out ;;
    "err" ) TYPE=err ;;
    "stderr" ) TYPE=err ;;
    * ) 
        echo "Nope, fuck you, bye!"
        exit 1
        ;;
esac

if [[ $TYPE == "out" ]]; then
    TYPE_SSH="OU"
    TYPE_JOB="stdout"
else
    TYPE_SSH="ER"
    TYPE_JOB="stderr"
fi

cat ~/jobs/.link_$ID/command.txt

echo Waiting for the job $ID to start...
while true; do
    if ! qstat $ID > /dev/null; then
        echo Job $ID has already finished
        qstat -x $ID
        cat ~/jobs/.link_$ID/$TYPE_JOB
        exit
    fi

    exec_host2=$(qstat -xf $ID | grep exec_host2)
    exec_host2=$(echo $exec_host2 | grep exec_host2)
    exec_host2=$(echo $exec_host2 | cut -d '=' -f 2)
    exec_host2=$(echo $exec_host2 | cut -d ':' -f 1)
    if [[ ! -z $exec_host2 ]]; then
        echo Connecting to job $ID on $exec_host2
        sleep 1 # to make sure host is running (and the output files are created)
        if ! ssh $exec_host2 "tail -n+1 -f /var/spool/pbs/spool/$ID*.$TYPE_SSH"
        then
            echo Job $ID already finished
            cat ~/jobs/.link_$ID/$TYPE_JOB
        fi
        exit 0
    fi
    sleep 5
done

