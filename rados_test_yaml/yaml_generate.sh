#!/bin/bash

#FILE_LIST=(cli_generic.sh concurrent.sh diff_continuous.sh diff.sh huge-tickets.sh image_read.sh import_export.sh issue-20295.sh journal.sh kernel.sh krbd_data_pool.sh krbd_exclusive_option.sh krbd_fallocate.sh krbd_stable_pages_required.sh map-snapshot-io.sh map-unmap.sh merge_diff.sh notify_master.sh notify_slave.sh permissions.sh qemu_dynamic_features.sh qemu-iotests.sh qemu_rebuild_object_map.sh rbd-ggate.sh rbd_mirror_ha.sh rbd_mirror_helpers.sh rbd_mirror.sh rbd_mirror_stress.sh rbd-nbd.sh read-flags.sh run_devstack_tempest.sh set_ro.py simple_big.sh smalliobench.sh test_admin_socket.sh test_librbd_api.sh test_librbd_python.sh test_librbd.sh test_lock_fence.sh test_rbdmap_RBDMAPFILE.sh test_rbd_mirror.sh verify_pool.sh)

FILE_LIST=(clone.sh load-gen-big.sh load-gen-mix.sh load-gen-mix-small-long.sh load-gen-mix-small.sh load-gen-mostlyread.sh stress_watch.sh test_alloc_hint.sh test_cache_pool.sh test_hang.sh test_pool_quota.sh test_python.sh test_rados_timeouts.sh test_rados_tool.sh test.sh test_tmap_to_omap.sh test-upgrade-v11.0.0.sh)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template ${file_name}.yaml
	sed -i "s/yaml_template.sh/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
