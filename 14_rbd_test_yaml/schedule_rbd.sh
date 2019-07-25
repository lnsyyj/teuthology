#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="3.1-RBD"

FILE_LIST=(cli_generic.sh.yaml diff_continuous.sh.yaml diff.sh.yaml import_export.sh.yaml issue-20295.sh.yaml journal.sh.yaml notify_master.sh.yaml notify_slave.sh.yaml permissions.sh.yaml qemu-iotests.sh.yaml rbd_groups.sh.yaml read-flags.sh.yaml test_librbd_api.sh.yaml test_librbd_python.sh.yaml test_librbd.sh.yaml test_lock_fence.sh.yaml test_rbd_mirror.sh.yaml verify_pool.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/14_rbd_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker plana
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
