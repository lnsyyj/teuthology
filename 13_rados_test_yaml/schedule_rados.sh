#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="3.0-RADOS"

FILE_LIST=(load-gen-big.sh load-gen-mix.sh load-gen-mix-small-long.sh load-gen-mix-small.sh load-gen-mostlyread.sh stress_watch.sh test_cache_pool.sh test_pool_access.sh test_pool_quota.sh test_rados_tool.sh test_tmap_to_omap.sh)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/13_rados_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker mira
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
