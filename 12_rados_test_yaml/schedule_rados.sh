#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="3.0-RADOS"

FILE_LIST=(load-gen-big.sh.yaml load-gen-mix.sh.yaml load-gen-mix-small-long.sh.yaml load-gen-mix-small.sh.yaml load-gen-mostlyread.sh.yaml test_cache_pool.sh.yaml test_pool_access.sh.yaml test_pool_quota.sh.yaml test_python.sh.yaml test_rados_timeouts.sh.yaml test_rados_tool.sh.yaml test_tmap_to_omap.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/12_rados_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker mira
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
