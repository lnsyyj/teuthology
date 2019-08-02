#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="NAS-FS"

FILE_LIST=(direct_io.py.yaml dirfrag.sh.yaml filelock_deadlock.py.yaml filelock_interrupt.py.yaml i_complete_vs_rename.sh.yaml layout_vxattrs.sh.yaml mkpool_layout_vxattrs.sh.yaml multiple_rsync.sh.yaml rstats.sh.yaml trivial_sync.sh.yaml xattrs.sh.yaml snap-rm-diff.sh.yaml snaptest-1.sh.yaml snaptest-2.sh.yaml snaptest-authwb.sh.yaml snaptest-capwb.sh.yaml snaptest-dir-rename.sh.yaml snaptest-double-null.sh.yaml snaptest-estale.sh.yaml snaptest-git-ceph.sh.yaml snaptest-hardlink.sh.yaml snaptest-intodir.sh.yaml snaptest-multiple-capsnaps.sh.yaml snaptest-parents.sh.yaml snaptest-realm-split.sh.yaml snaptest-snap-rename.sh.yaml snaptest-snap-rm-cmp.sh.yaml snaptest-upchildrealms.sh.yaml snaptest-xattrwb.sh.yaml quota.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/14_fs_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker plana
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
