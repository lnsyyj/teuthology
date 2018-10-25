#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="CEPH_TEST"

FILE_LIST=(ceph_omapbench.yaml ceph_test_cls_lock.yaml ceph_test_cls_rgw.yaml ceph_test_mon_msg.yaml ceph_test_rados_api_cmd.yaml ceph_test_rados_api_nlist.yaml ceph_test_rados_striper_api_io.yaml ceph_perf_local.yaml ceph_test_cls_log.yaml ceph_test_cls_statelog.yaml ceph_test_msgr.yaml ceph_test_rados_api_c_read_operations.yaml ceph_test_rados_api_pool.yaml ceph_test_rados_watch_notify.yaml ceph_scratchtool.yaml ceph_test_cls_numops.yaml ceph_test_cls_version.yaml ceph_test_object_map.yaml ceph_test_rados_api_c_write_operations.yaml ceph_test_rados_delete_pools_parallel.yaml ceph_test_snap_mapper.yaml ceph_test_async_driver.yaml ceph_test_cls_rbd.yaml ceph_test_filejournal.yaml ceph_test_objectstore.yaml ceph_test_rados_api_list.yaml ceph_test_rados_list_parallel.yaml ceph_test_stress_watch.yaml ceph_test_cls_hello.yaml ceph_test_cls_refcount.yaml ceph_test_filestore.yaml ceph_test_rados_api_aio.yaml ceph_test_rados_api_lock.yaml ceph_test_rados_open_pools_parallel.yaml ceph_tpbench.yaml ceph_test_cls_journal.yaml ceph_test_cls_replica_log.yaml ceph_test_keyvaluedb.yaml ceph_test_rados_api_cls.yaml ceph_test_rados_api_misc.yaml ceph_test_rados_striper_api_aio.yaml)

function activate() {
        source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/ceph_test_rpm_yaml/

for file_name in ${FILE_LIST[@]}
do
        teuthology-schedule --name "${DATA}-${SUITE}" ${file_name}
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
