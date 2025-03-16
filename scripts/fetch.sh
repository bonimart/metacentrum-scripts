#!/bin/bash
# Fetch your "labs" and "metacentrum" directory to your metacentrum storage.
# When run fetches all the files from the remote
# Then sends new files to the remote
# Then tracks local files and updates them on the remote
# Does not track file changes on the remote, restart is needed

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

DIRS="./labs"

# Start jobs
for DIR in $DIRS; do
    echo Fetching $DIR
    rsync -azuptPE --delete metacentrum:"~/${DIR}/" "${DIR}/" 
done

echo Done

