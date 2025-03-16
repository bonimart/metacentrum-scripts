#!/bin/bash
# Sync a single folder to your metacentrum storage
# tracks local file changes and updates them on the remote.
# Does not track file changes on the remote, use ./fetch.sh

# REQUIREMENTS (otherwise rsync will fail upon asking for password):
#
# 1. Generate ssh key
#
# 2. Add this to your ~/.ssh/config
#
# Host metacentrum
#   HostName tarkil.grid.cesnet.cz
#   IdentityFile ~/.ssh/KEYNAME
#   User USERNAME
#   PubKeyAuthentication yes
#   AddKeysToAgent yes
#
# 3. Copy public key to metacentrum
#
# ssh-copy-id -i ~/.ssh/KEYNAME.pub USERNAME@tarkil.grid.cesnet.cz

if [[ ! -d $1 ]]; then
   echo "Usage: $0 DIR"
   exit 1
fi
DIR=$1
CHMOD="--chmod=Du=rwx,Dg=,Do=,Fu=rwx,Fg=,Fo="

# Observe file changes
function observe_files {
    DIR=$1
    # -e close_write \
    inotifywait -mr \
        --timefmt '%d/%m/%y %H:%M' --format '%T %w %f %e' \
        -e create \
        -e delete \
        -e modify \
        -e move \
        ${DIR} |
        while read -r date time dir file events; do
            changed_abs=${dir}${file}
            # changed_rel=${changed_abs#"$cwd"/}

            echo "[$(date)]: Syncing ./$dir ($changed_abs) ($events)"
            rsync -azuptPE $CHMOD --delete "./$dir" metacentrum:"~/$dir"
    done
}

read -p "Did you run ./fetch.sh (to prevent logs loss)? "

# Start jobs
echo Initial sync $DIR
rsync -azuptPE $CHMOD --delete "${DIR}/" metacentrum:"~/${DIR}/"
observe_files "$DIR" &

# Kill jobs on exit
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Wait for jobs
read -p "Press any key to finish ..."
