#!/bin/bash

FILE_LIST=(load-gen-big.sh load-gen-mix.sh load-gen-mix-small-long.sh load-gen-mix-small.sh load-gen-mostlyread.sh stress_watch.sh test_cache_pool.sh test_pool_access.sh test_pool_quota.sh test_rados_tool.sh test_tmap_to_omap.sh)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template ${file_name}.yaml
	sed -i "s/yaml_template.sh/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
