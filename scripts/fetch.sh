#!/bin/bash
# Fetch directory from metacentrum

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

echo Fetching $DIR
rsync -zurtPE --chmod=F644,D755 metacentrum:"~/${DIR}/" "${DIR}/" 
echo Done

