#!/bin/bash
set -x

DATA=$(date +%Y-%m-%d)
SUITE="RBD"
echo ${DATA}
MACHINES_TOTAL=4
MACHINES_LIST=(plana003.test.lenovo.com plana004.test.lenovo.com plana005.test.lenovo.com plana006.test.lenovo.com)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

function keep_unlock_machine() {
	RESULT=$(teuthology-lock --summary | grep free | grep ${MACHINES_TOTAL})
	echo ${RESULT}
	if [ "${RESULT}" = "" ]; then
		echo "is null"
		OWNER=$(teuthology-lock --summary | grep teuthology | awk '{print $4}')
		LEN=${#MACHINES_LIST[@]}
		for ((i=0; i<${LEN}; i++))
		do
			teuthology-lock --owner ${OWNER} --unlock ${MACHINES_LIST[${i}]}
		done
	else
		echo "not null"
	fi
}

activate
keep_unlock_machine


# yum install cronie crontabs -y
# yum list cronie && systemctl status crond
# crontab -e
# */1 * * * * /home/teuthology/src/teuthology_master/rbd_test_yaml/unlock_machines.sh 
