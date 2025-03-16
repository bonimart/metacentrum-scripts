#!/bin/bash
# Fetch your "labs" and "metacentrum" directory to your metacentrum storage.
# When run fetches all the files from the remote
# Then sends new files to the remote
# Then tracks local files and updates them on the remote
# Does not track file changes on the remote, restart is needed

# Add this to your ~/.ssh/config
# Host metacentrum
#   HostName tarkil.grid.cesnet.cz
#   IdentityFile ~/.ssh/KEYNAME
#   User USERNAME
#   PubKeyAuthentication yes
#   AddKeysToAgent yes

DIRS="./labs"

# Start jobs
for DIR in $DIRS; do
    echo Fetching $DIR
    rsync -azuptPE --delete metacentrum:"~/${DIR}/" "${DIR}/" 
done

echo Done

