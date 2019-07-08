#!/bin/bash

FILE_LIST=(cli_generic.sh diff_continuous.sh diff.sh import_export.sh issue-20295.sh journal.sh merge_diff.sh notify_master.sh notify_slave.sh permissions.sh qemu_dynamic_features.sh qemu-iotests.sh qemu_rebuild_object_map.sh rbd_groups.sh read-flags.sh test_admin_socket.sh test_librbd_api.sh test_librbd_python.sh test_librbd.sh test_lock_fence.sh test_rbd_mirror.sh verify_pool.sh)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template ${file_name}.yaml
	sed -i "s/yaml_template.sh/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
