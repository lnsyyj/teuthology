#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="RADOS"

FILE_LIST=(load-gen-big.sh.yaml load-gen-mix.sh.yaml load-gen-mix-small-long.sh.yaml load-gen-mix-small.sh.yaml load-gen-mostlyread.sh.yaml stress_watch.sh.yaml test_cache_pool.sh.yaml test_pool_quota.sh.yaml test_python.sh.yaml test_rados_timeouts.sh.yaml test_rados_tool.sh.yaml test_tmap_to_omap.sh.yaml)
#FILE_LIST=(clone.sh.yaml load-gen-big.sh.yaml load-gen-mix.sh.yaml load-gen-mix-small-long.sh.yaml load-gen-mix-small.sh.yaml load-gen-mostlyread.sh.yaml stress_watch.sh.yaml test_alloc_hint.sh.yaml test_cache_pool.sh.yaml test_hang.sh.yaml test_pool_quota.sh.yaml test_python.sh.yaml test_rados_timeouts.sh.yaml test_rados_tool.sh.yaml test.sh.yaml test_tmap_to_omap.sh.yaml test-upgrade-v11.0.0.sh.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/rados_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name}
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
