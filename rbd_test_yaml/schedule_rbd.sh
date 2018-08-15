#!/bin/bash
set -x

DATA=$(date +%Y-%m-%d)
SUITE="RBD"
echo ${DATA}
activate () {
  source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

#su - paddles -c "source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate"
activate
teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml
teuthology-schedule --name "${DATA}-${SUITE}" import_export.yaml
teuthology-schedule --name "${DATA}-${SUITE}" diff_continuous.yaml
teuthology-schedule --name "${DATA}-${SUITE}" copy.yaml
teuthology-schedule --name "${DATA}-${SUITE}" concurrent.yaml
