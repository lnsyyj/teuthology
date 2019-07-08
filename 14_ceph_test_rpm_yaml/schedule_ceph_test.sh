#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="3.1-CEPH_TEST"

FILE_LIST=(ceph_test_async_driver.yaml ceph_test_async_networkstack.yaml ceph_test_cls_hello.yaml ceph_test_cls_journal.yaml ceph_test_cls_lock.yaml ceph_test_cls_log.yaml ceph_test_cls_lua.yaml ceph_test_cls_numops.yaml ceph_test_cls_rbd.yaml ceph_test_cls_refcount.yaml ceph_test_cls_rgw.yaml ceph_test_cls_sdk.yaml ceph_test_filejournal.yaml ceph_test_filestore_idempotent_sequence.yaml ceph_test_keyvaluedb.yaml ceph_test_libcephfs.yaml ceph_test_libcephfs_access.yaml ceph_test_libcephfs_reclaim.yaml ceph_test_msgr.yaml ceph_test_rados_api_aio.yaml ceph_test_rados_api_aio_pp.yaml ceph_test_rados_api_asio.yaml ceph_test_rados_api_cmd.yaml ceph_test_rados_api_cmd_pp.yaml ceph_test_rados_api_c_read_operations.yaml ceph_test_rados_api_c_write_operations.yaml ceph_test_rados_api_io.yaml ceph_test_rados_api_io_pp.yaml ceph_test_rados_api_list.yaml ceph_test_rados_api_lock.yaml ceph_test_rados_api_lock_pp.yaml ceph_test_rados_api_misc.yaml ceph_test_rados_api_misc_pp.yaml ceph_test_rados_api_pool.yaml ceph_test_rados_api_service.yaml ceph_test_rados_api_service_pp.yaml ceph_test_rados_api_snapshots.yaml ceph_test_rados_api_snapshots_pp.yaml ceph_test_rados_api_stat.yaml ceph_test_rados_api_stat_pp.yaml ceph_test_rados_api_tier_pp.yaml ceph_test_rados_api_watch_notify.yaml ceph_test_rados_api_watch_notify_pp.yaml ceph_test_rados_delete_pools_parallel.yaml ceph_test_rados_list_parallel.yaml ceph_test_rados_open_pools_parallel.yaml ceph_test_rados_striper_api_aio.yaml ceph_test_rados_striper_api_io.yaml ceph_test_rados_striper_api_striping.yaml ceph_test_rados_watch_notify.yaml ceph_test_rbd_mirror.yaml ceph_test_stress_watch.yaml ceph_test_trim_caps.yaml)

function activate() {
        source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/14_ceph_test_rpm_yaml/

for file_name in ${FILE_LIST[@]}
do
        teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker plana
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
