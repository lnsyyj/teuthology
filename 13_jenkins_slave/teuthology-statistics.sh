#!/bin/bash
set -x

TEUTHOLOGY_NODE="192.168.0.14"

function remote_teuthology_statistics() {
	ssh "root@${TEUTHOLOGY_NODE}" "python /home/teuthology/src/teuthology_master/12_rbd_test_yaml/teuthology_statistics.py"
}

remote_teuthology_statistics
