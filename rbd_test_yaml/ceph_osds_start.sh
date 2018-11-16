#!/bin/bash
set -x
CEPH_NODE="192.168.0.17"

ssh "root@${CEPH_NODE}" "/etc/init.d/ceph -a start"


# yum install cronie crontabs -y
# yum list cronie && systemctl status crond
# crontab -e
# */5 * * * * /home/teuthology/src/teuthology_master/rbd_test_yaml/ceph_osds_start.sh
