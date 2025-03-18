#!/bin/bash
# Schedules the next python job
# Usage: ./schedule.sh file.py [args...]
# Uses Prague only, fast venv init
#
# [Args]
# use export NAME=idk to set the args
# 
# uses WALL_TIME env variable = total time the job can run for [hours], defaults to 6

START_SECONDS=${SECONDS}
START_UNIX=$(date +%s)
LOGS_DIR=logs
VENV_DIR=.venv
DATADIR=/storage/praha1/home/${USER}

SRC_DIR=$(dirname "./$1")
SRC_FILE=$(basename "./$1")
# first argument is the filename
# the rest are args for the python script
COMMAND="${SRC_FILE} ${@:2} --timestamp ${START_UNIX}"

if [[ ! -f "./${SRC_DIR}/${SRC_FILE}" ]]; then
    echo "The first argument '${SRC_FILE}' is not a valid file."
    exit 1
fi


# Set default wall time
if [[ -z "${WALL_TIME}" ]]; then
    echo Setting WALL_TIME to 6h
    WALL_TIME="6"
fi
WALL_TIME="${WALL_TIME}:00:00"


# date '+%Y-%m-%d_%H-%M-%S'
JOB_NAME="${SRC_FILE}_$(date '+%m%d-%H%M%S')"
JOB_DIR="job_${JOB_NAME}"
JOB_DIR_PATH="jobs/${JOB_DIR}"
JOB_FILE="job.sh"
COMMAND_FILE="command.txt"
echo "Job name: ${JOB_NAME}"
echo "Data dir: ${DATADIR}/${JOB_DIR_PATH}"
mkdir -p ${DATADIR}/${JOB_DIR_PATH}
echo "Command:  ${COMMAND}"
echo python3 ${COMMAND} > ${DATADIR}/${JOB_DIR_PATH}/${COMMAND_FILE}

mkdir -p "${DATADIR}/${JOB_DIR_PATH}/${SRC_DIR}"
cp -r "${DATADIR}/${SRC_DIR}/." "${DATADIR}/${JOB_DIR_PATH}/${SRC_DIR}/"


cat > "${JOB_DIR_PATH}/${JOB_FILE}" << EOF
#!/bin/bash
#PBS -N ${JOB_NAME}
#PBS -q gpu
#PBS -l select=1:ncpus=4:mem=16gb:ngpus=1:gpu_mem=8gb:scratch_shm=true
#PBS -l walltime=${WALL_TIME}
#PBS -o ${DATADIR}/${JOB_DIR_PATH}/stdout
#PBS -e ${DATADIR}/${JOB_DIR_PATH}/stderr
#
###############################################################################
# python3 $COMMAND
###############################################################################

echo DATADIR    = ${DATADIR}
echo SCRATCHDIR = \$SCRATCHDIR
echo SRC_DIR    = ${SRC_DIR}
echo SRC_FILE   = ${SRC_FILE}
echo JOB_DIR    = ${JOB_DIR_PATH}
echo JOB_NAME   = ${JOB_NAME}

export TMPDIR=\$SCRATCHDIR
trap 'clean_scratch' TERM EXIT

module add python/3.11.11-gcc-10.2.1-555dlyc

cd \$SCRATCHDIR
echo Copying labs
mkdir -p ./${SRC_DIR}
cp -r ${DATADIR}/${JOB_DIR_PATH}/${SRC_DIR}/. ./${SRC_DIR}/ || { echo >&2 "Error while copying labs!"; exit 2; }

echo Extracting virtual environment
tar -I pigz -x --checkpoint=10000 -f ${DATADIR}/${VENV_DIR}.tar.gz || { echo >&2 "Error while extracting venv!"; exit 2; }
echo Virtual environment extracted
ls -a

echo Running ${SRC_FILE}
cd ${SRC_DIR}

if [[ -d ${LOGS_DIR} ]]; then
rm -rf ./${LOGS_DIR}
fi

ls -a
\$SCRATCHDIR/${VENV_DIR}/bin/python3 ${COMMAND} || { echo >&2 "Calculation ended up erroneously (with a code \$?) !!"; exit 3; }
echo Running done

# move the output to user's DATADIR or exit in case of failure
echo Copying the '${LOGS_DIR}' folder
cp -r ${LOGS_DIR}/. ${DATADIR}/${JOB_DIR_PATH}/${LOGS_DIR}/ || { echo >&2 "Logs copying failed (to job) (with a code \$?) !!"; exit 4; }
cp ${DATADIR}/${JOB_DIR_PATH}/${JOB_FILE} ${LOGS_DIR}/*/
cp ${DATADIR}/${JOB_DIR_PATH}/${COMMAND_FILE} ${LOGS_DIR}/*/
cp -r ${LOGS_DIR}/. ${DATADIR}/${SRC_DIR}/${LOGS_DIR}/ || { echo >&2 "Logs copying failed (to src) (with a code \$?) !!"; exit 4; }
EOF

chmod +x "${JOB_DIR_PATH}/${JOB_FILE}"
JOB_ID=$(qsub "${JOB_DIR_PATH}/${JOB_FILE}")
ln -s $JOB_DIR jobs/.link_$(echo ${JOB_ID} | cut -d '.' -f 1)
echo Job id: ${JOB_ID}
echo wqstat ${JOB_ID}
echo ./scripts/view_stdout.sh ${JOB_ID}
echo

# if there are multiple batches in the row,
# we need to store then in different folders
# we need at least 1 sec difference
while [[ ${START_SECONDS} == ${SECONDS} ]]; do
		sleep .01
done

