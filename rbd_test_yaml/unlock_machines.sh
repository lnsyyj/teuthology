#!/bin/bash
set -x

DATA=$(date +%Y-%m-%d)
SUITE="RBD"
echo ${DATA}
MACHINES_TOTAL=4
MACHINES_LIST_PLANA=(plana003.test.lenovo.com plana004.test.lenovo.com plana005.test.lenovo.com plana006.test.lenovo.com)
MACHINES_LIST_MIRA=(mira003.test.lenovo.com mira004.test.lenovo.com mira005.test.lenovo.com mira006.test.lenovo.com)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

function keep_unlock_machine_plana() {
	RESULT=$(teuthology-lock --summary | grep free | grep plana | grep ${MACHINES_TOTAL})
	echo ${RESULT}
	if [ "${RESULT}" = "" ]; then
		echo "is null"
		OWNER=$(teuthology-lock --summary | grep teuthology | awk '{print $4}')
		LEN=${#MACHINES_LIST_PLANA[@]}
		for ((i=0; i<${LEN}; i++))
		do
			teuthology-lock --owner ${OWNER} --unlock ${MACHINES_LIST_PLANA[${i}]}
		done
	else
		echo "not null"
	fi
}

function keep_unlock_machine_mira() {
	RESULT=$(teuthology-lock --summary | grep free | grep mira | grep ${MACHINES_TOTAL})
	echo ${RESULT}
	if [ "${RESULT}" = "" ]; then
		echo "is null"
		OWNER=$(teuthology-lock --summary | grep teuthology | awk '{print $4}')
		LEN=${#MACHINES_LIST_MIRA[@]}
		for ((i=0; i<${LEN}; i++))
		do
			teuthology-lock --owner ${OWNER} --unlock ${MACHINES_LIST_MIRA[${i}]}
		done
	else
		echo "not null"
	fi
}
activate
keep_unlock_machine_plana
keep_unlock_machine_mira


# yum install cronie crontabs -y
# yum list cronie && systemctl status crond
# crontab -e
# */1 * * * * /home/teuthology/src/teuthology_master/rbd_test_yaml/unlock_machines.sh 
