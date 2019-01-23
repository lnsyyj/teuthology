#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="3.0-RBD"

FILE_LIST=(cli_generic.sh diff_continuous.sh diff.sh import_export.sh issue-20295.sh journal.sh notify_master.sh notify_slave.sh rbd_groups.sh read-flags.sh test_librbd_api.sh test_librbd_python.sh test_librbd.sh test_lock_fence.sh verify_pool.sh)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/13_rbd_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker mira
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
