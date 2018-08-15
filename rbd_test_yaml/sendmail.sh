#!/bin/bash
set -x

DATA=$(date +%Y-%m-%d)
SUITE="RBD"
echo ${DATA}
function activate() {
	source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
teuthology-results --email yujiang2@lenovo.com --timeout 1 --archive-dir /home/teuthworker/archive --name "${DATA}-RBD" --subset rbd --seed 1
teuthology-results --email yujiang2@lenovo.com --timeout 1 --archive-dir /home/teuthworker/archive --name "${DATA}-RADOS" --subset rados --seed 1
