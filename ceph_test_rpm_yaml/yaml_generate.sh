#!/bin/bash

#FILE_LIST=(cli_generic.sh concurrent.sh diff_continuous.sh diff.sh huge-tickets.sh image_read.sh import_export.sh issue-20295.sh journal.sh kernel.sh krbd_data_pool.sh krbd_exclusive_option.sh krbd_fallocate.sh krbd_stable_pages_required.sh map-snapshot-io.sh map-unmap.sh merge_diff.sh notify_master.sh notify_slave.sh permissions.sh qemu_dynamic_features.sh qemu-iotests.sh qemu_rebuild_object_map.sh rbd-ggate.sh rbd_mirror_ha.sh rbd_mirror_helpers.sh rbd_mirror.sh rbd_mirror_stress.sh rbd-nbd.sh read-flags.sh run_devstack_tempest.sh set_ro.py simple_big.sh smalliobench.sh test_admin_socket.sh test_librbd_api.sh test_librbd_python.sh test_librbd.sh test_lock_fence.sh test_rbdmap_RBDMAPFILE.sh test_rbd_mirror.sh verify_pool.sh)

FILE_LIST=(ceph_omapbench ceph_perf_local ceph_scratchtool ceph_test_async_driver ceph_test_cls_hello ceph_test_cls_journal ceph_test_cls_lock ceph_test_cls_log ceph_test_cls_numops ceph_test_cls_rbd ceph_test_cls_refcount ceph_test_cls_replica_log ceph_test_cls_rgw ceph_test_cls_statelog ceph_test_cls_version ceph_test_filejournal ceph_test_filestore ceph_test_keyvaluedb ceph_test_mon_msg ceph_test_msgr ceph_test_object_map ceph_test_objectstore ceph_test_rados_api_aio ceph_test_rados_api_cls ceph_test_rados_api_cmd ceph_test_rados_api_c_read_operations ceph_test_rados_api_c_write_operations ceph_test_rados_api_list ceph_test_rados_api_lock ceph_test_rados_api_misc ceph_test_rados_api_nlist ceph_test_rados_api_pool ceph_test_rados_delete_pools_parallel ceph_test_rados_list_parallel ceph_test_rados_open_pools_parallel ceph_test_rados_striper_api_aio ceph_test_rados_striper_api_io ceph_test_rados_watch_notify ceph_test_snap_mapper ceph_test_stress_watch ceph_tpbench ceph_test_mutate ceph_test_rados_api_io ceph_test_rados_api_snapshots ceph_test_rados_api_stat ceph_test_rados_api_tier ceph_test_rados_api_tmap_migrate ceph_test_rados_api_watch_notify ceph_test_rbd_mirror)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template ${file_name}.yaml
	sed -i "s/yaml_template/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
