#!/bin/bash

FILE_LIST=(quota.sh)

COUNT=1
for file_name in ${FILE_LIST[@]}
do
	cp yaml_template_quota ${file_name}.yaml
	sed -i "s/yaml_template.sh/${file_name}/g" ${file_name}.yaml
        echo ${COUNT}
	COUNT=$((${COUNT}+1))
done
