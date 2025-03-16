#!/bin/bash
# Sync your "labs" and "metacentrum" directory to your metacentrum storage.
# Sends new files to the remote and
# tracks local file changes and updates them on the remote.
# Does not track file changes on the remote, use ./fetch.sh

# Add this to your ~/.ssh/config
# Host metacentrum
#   HostName tarkil.grid.cesnet.cz
#   IdentityFile ~/.ssh/KEYNAME
#   User USERNAME
#   PubKeyAuthentication yes
#   AddKeysToAgent yes

DIRS="./labs ./scripts"
CHMOD="--chmod=Du=rwx,Dg=,Do=,Fg=,Fo="

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
            rsync -dzuptPE $CHMOD --delete "./$dir" metacentrum:"~/$dir"
    done
}

read -p "Did you run ./fetch.sh (to prevent logs loss)? "

# Start jobs
for DIR in $DIRS; do
    echo Initial sync $DIR
    rsync -azuptPE $CHMOD --delete "${DIR}/" metacentrum:"~/${DIR}/"
    observe_files "$DIR" &
done

# Kill jobs on exit
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Wait for jobs
read -p "Press any key to finish ..."
