#!/bin/bash

FILE_LIST=(ceph_test_async_driver ceph_test_async_networkstack ceph_test_cls_hello ceph_test_cls_journal ceph_test_cls_lock ceph_test_cls_log ceph_test_cls_lua ceph_test_cls_numops ceph_test_cls_rbd ceph_test_cls_refcount ceph_test_cls_rgw ceph_test_cls_sdk ceph_test_filejournal ceph_test_filestore_idempotent_sequence ceph_test_keyvaluedb ceph_test_libcephfs ceph_test_libcephfs_access ceph_test_libcephfs_reclaim ceph_test_librbd ceph_test_librbd_api ceph_test_msgr ceph_test_rados_api_aio ceph_test_rados_api_aio_pp ceph_test_rados_api_asio ceph_test_rados_api_cmd ceph_test_rados_api_cmd_pp ceph_test_rados_api_c_read_operations ceph_test_rados_api_c_write_operations ceph_test_rados_api_io ceph_test_rados_api_io_pp ceph_test_rados_api_list ceph_test_rados_api_lock ceph_test_rados_api_lock_pp ceph_test_rados_api_misc ceph_test_rados_api_misc_pp ceph_test_rados_api_pool ceph_test_rados_api_service ceph_test_rados_api_service_pp ceph_test_rados_api_snapshots ceph_test_rados_api_snapshots_pp ceph_test_rados_api_stat ceph_test_rados_api_stat_pp ceph_test_rados_api_tier_pp ceph_test_rados_api_watch_notify ceph_test_rados_api_watch_notify_pp ceph_test_rados_delete_pools_parallel ceph_test_rados_list_parallel ceph_test_rados_open_pools_parallel ceph_test_rados_striper_api_aio ceph_test_rados_striper_api_io ceph_test_rados_striper_api_striping ceph_test_rados_watch_notify ceph_test_rbd_mirror ceph_test_stress_watch ceph_test_trim_caps)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template ${file_name}.yaml
	sed -i "s/yaml_template/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done