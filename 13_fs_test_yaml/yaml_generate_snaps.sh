#!/bin/bash

FILE_LIST=(snap-rm-diff.sh snaptest-1.sh snaptest-2.sh snaptest-authwb.sh snaptest-capwb.sh snaptest-dir-rename.sh snaptest-double-null.sh snaptest-estale.sh snaptest-git-ceph.sh snaptest-hardlink.sh snaptest-intodir.sh snaptest-multiple-capsnaps.sh snaptest-parents.sh snaptest-realm-split.sh snaptest-snap-rename.sh snaptest-snap-rm-cmp.sh snaptest-upchildrealms.sh snaptest-xattrwb.sh)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template_snaps ${file_name}.yaml
	sed -i "s/yaml_template.sh/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
