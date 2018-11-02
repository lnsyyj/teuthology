#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="RBD"
#FILE_LIST=(import_export.yaml verify_pool.yaml diff_continuous.yaml copy.yaml concurrent.yaml)

#FILE_LIST=(copy.sh.yaml diff.sh.yaml import_export.sh.yaml journal.sh.yaml permissions.sh.yaml qemu-iotests.sh.yaml rbd_mirror_helpers.sh.yaml rbd_mirror.sh.yaml rbd_mirror_stress.sh.yaml rbd-nbd.sh.yaml read-flags.sh.yaml run_cli_tests.sh.yaml smalliobench.sh.yaml test_admin_socket.sh.yaml test_librbd_python.sh.yaml test_librbd.sh.yaml test_rbdmap_RBDMAPFILE.sh.yaml test_rbd_mirror.sh.yaml verify_pool.sh.yaml diff_continuous.sh.yaml test_librbd_api.sh.yaml notify_master.sh.yaml test_lock_fence.sh.yaml notify_slave.sh.yaml merge_diff.sh.yaml)
FILE_LIST=(copy.sh.yaml diff.sh.yaml import_export.sh.yaml journal.sh.yaml permissions.sh.yaml qemu-iotests.sh.yaml rbd-nbd.sh.yaml read-flags.sh.yaml run_cli_tests.sh.yaml smalliobench.sh.yaml test_admin_socket.sh.yaml test_librbd_python.sh.yaml test_librbd.sh.yaml test_rbdmap_RBDMAPFILE.sh.yaml test_rbd_mirror.sh.yaml verify_pool.sh.yaml diff_continuous.sh.yaml test_librbd_api.sh.yaml notify_master.sh.yaml test_lock_fence.sh.yaml notify_slave.sh.yaml merge_diff.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/rbd_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name}
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
