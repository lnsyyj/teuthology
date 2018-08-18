#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="RBD"
#FILE_LIST=(import_export.yaml verify_pool.yaml diff_continuous.yaml copy.yaml concurrent.yaml)

FILE_LIST=(copy.sh.yaml diff.sh.yaml image_read.sh.yaml import_export.sh.yaml journal.sh.yaml kernel.sh.yaml map-snapshot-io.sh.yaml map-unmap.sh.yaml merge_diff.sh.yaml notify_master.sh.yaml notify_slave.sh.yaml permissions.sh.yaml qemu_dynamic_features.sh.yaml qemu-iotests.sh.yaml qemu_rebuild_object_map.sh.yaml rbd_mirror_helpers.sh.yaml rbd_mirror.sh.yaml rbd_mirror_stress.sh.yaml rbd-nbd.sh.yaml read-flags.sh.yaml run_cli_tests.sh.yaml set_ro.py.yaml simple_big.sh.yaml smalliobench.sh.yaml test_admin_socket.sh.yaml test_librbd_api.sh.yaml test_librbd_python.sh.yaml test_librbd.sh.yaml test_lock_fence.sh.yaml test_rbdmap_RBDMAPFILE.sh.yaml test_rbd_mirror.sh.yaml verify_pool.sh.yaml concurrent.sh.yaml diff_continuous.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/rbd_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name}
done

#teuthology-schedule --name "${DATA}-${SUITE}" import_export.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" diff_continuous.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" copy.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" concurrent.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" run_cli_tests.sh.yaml

popd
