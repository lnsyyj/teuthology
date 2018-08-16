#!/bin/bash
set -x

DATA=$(date +%Y-%m-%d)
SUITE="RBD"
#FILE_LIST=(import_export.yaml verify_pool.yaml diff_continuous.yaml copy.yaml concurrent.yaml)

FILE_LIST=(import_export.yaml verify_pool.yaml)

function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/rbd_test_yaml/

for file_name in ${FILE_LIST[@]}
do
	teuthology-schedule --name "${DATA}-${SUITE}" ${file_name}
done

#teuthology-schedule --name "${DATA}-${SUITE}" import_export.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" diff_continuous.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" copy.yaml
#teuthology-schedule --name "${DATA}-${SUITE}" concurrent.yaml

popd
