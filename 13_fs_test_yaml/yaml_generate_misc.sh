#!/bin/bash

FILE_LIST=(direct_io.py dirfrag.sh filelock_deadlock.py filelock_interrupt.py i_complete_vs_rename.sh layout_vxattrs.sh mkpool_layout_vxattrs.sh rstats.sh trivial_sync.sh xattrs.sh)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template_misc ${file_name}.yaml
	sed -i "s/yaml_template.sh/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
