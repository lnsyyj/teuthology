#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="NAS-RADOS"

FILE_LIST=(load-gen-big.sh.yaml load-gen-mix.sh.yaml load-gen-mix-small-long.sh.yaml load-gen-mix-small.sh.yaml load-gen-mostlyread.sh.yaml stress_watch.sh.yaml test_cache_pool.sh.yaml test_dedup_tool.sh.yaml test_pool_access.sh.yaml test_pool_quota.sh.yaml test_python.sh.yaml test_rados_tool.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/14_rados_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker plana
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
