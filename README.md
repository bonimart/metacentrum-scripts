# Metacentrum scrips

## 2025 Working scripts

### File sync

- [x] `sync.sh` - continuous sync of local directory to metacentrum
- [x] `fetch.sh` - single fetch of metacentrum directory

### Job scheduling

- [x] `venv_init.sh` - create virtual environment and save it as tarball in home directory
- [x] `schedule.sh` - schedule job with given script and parameters

### Job monitoring

## Requirements for file sync

1. Generate ssh key
2. Add this to your ~/.ssh/config

```
Host metacentrum
  HostName tarkil.grid.cesnet.cz
  IdentityFile ~/.ssh/KEYNAME
  User USERNAME
  PubKeyAuthentication yes
  AddKeysToAgent yes
```

3. Copy public key to metacentrum via

`ssh-copy-id -i ~/.ssh/KEYNAME.pub USERNAME@tarkil.grid.cesnet.cz`

## Example workflow

1. Sync these scripts by calling `scripts/sync.sh scripts`
2. Enter metacentrum frontend via ssh
3. Create virtual environment via `qsub scripts/venv_init.sh`
4. Sync your `labs` directory of the deep (reinforcement) learning course via `sync.sh`
5. Schedule jobs via `scripts/schedule.sh <script> <params>`
6. Fetch results back to your local machine via `fetch.sh`
7. Profit

## Former readme

This repository stores scripts that I used to work with the Metacentrum
clusters during Deep learning class at MFF CU 2024.
These scrips are working fine, but are not well documented
(see description in individual scrips).
Also, there may quite possibly simple approach, I just haven't found it.

There are two main types of scrips: job scheduling and file synchronization.
I don't recommend using the file synchronization scrips unless you read
them yourself as inappropriate handing
can delete your local versions of the files.

Scheduling scrips provide job scheduling capability and data discovery.
All the job outputs you run are stored in the `~/jobs` directory,
but only if the job succeed. Otherwise, only logs are stored.
The logs can be browsed using other scrips.

> Read docs inside the scrips before running them!

First you need to schedule the `./create_env_job.sh` job with `qsub`
to create a compressed virtual environment.
Expected workflow is to write your model,
sync it to the cluster and
schedule a bunch of jobs using multiple `./schedule.sh script params`.
Then observer the status using the `./jobs.sh` command
You can view the results using `./browse.sh`,
`./view_stdout.sh` or in the `jobs` directory.
For more read Metacentrum docs and see the scrips.

I recommend you do a fork in case you need to do small adjustments
related to your personal workflow.

Good luck passing the subject!

