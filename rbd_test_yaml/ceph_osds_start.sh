#!/bin/bash
set -x
CEPH_NODE_14="192.168.0.17"
CEPH_NODE_13="192.168.0.60"

#ssh "root@${CEPH_NODE_14}" "/etc/init.d/ceph -a start"
ssh "root@${CEPH_NODE_13}" "/etc/init.d/ceph -a start"


# yum install cronie crontabs -y
# yum list cronie && systemctl status crond
# crontab -e
# */5 * * * * /home/teuthology/src/teuthology_master/rbd_test_yaml/ceph_osds_start.sh
