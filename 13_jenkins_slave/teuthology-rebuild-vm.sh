#!/bin/sh
export OS_NO_CACHE='true'
export OS_DOMAIN_NAME='ECR-ops'
export OS_PROJECT_NAME='sunlei5'
export OS_USERNAME='sunlei5'
export OS_USER_DOMAIN_NAME='ECR-ops'
export OS_PASSWORD='passw0rd'
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_URL='http://10.121.8.3:5000/v3/'
export OS_AUTH_STRATEGY='keystone'
export OS_AUTH_TYPE='password'
export OS_REGION_NAME='RegionOne'
export CINDER_ENDPOINT_TYPE='publicURL'
export GLANCE_ENDPOINT_TYPE='publicURL'
export KEYSTONE_ENDPOINT_TYPE='publicURL'
export NOVA_ENDPOINT_TYPE='publicURL'
export NEUTRON_ENDPOINT_TYPE='publicURL'
# We use glance api-version v1 currently, but glance client defaults to v2
export OS_IMAGE_API_VERSION='1'

# 
# 
# 
set -x

MACHINE_LIST=(teuthology-sds-controller-mira mira003 mira004 mira005 mira006)
MACHINE_IP=(192.168.0.65 192.168.0.60 192.168.0.61 192.168.0.62 192.168.0.63)
MACHINE_PASSWORD="yujiang2"

RESULT=""
PING_RESULT=""

function turn_off_the_virtual_machine() {
    openstack server stop $1
}

function check_virtual_machine_status() {
    RESULT=$(openstack server show $1 | grep '|\ status' | awk '{print $4}' | sed 's/[ \t]*$//g')
}

function rebuild_virtual_machine() {
    openstack server rebuild teuthology-sds-controller-mira --image CentOS-7-x86_64-v5 --password ${MACHINE_PASSWORD}
    openstack server rebuild mira003 --image 2018-11-29-mira003-snap --password ${MACHINE_PASSWORD}
    openstack server rebuild mira004 --image 2018-11-29-mira004-snap --password ${MACHINE_PASSWORD}
    openstack server rebuild mira005 --image 2018-11-29-mira005-snap --password ${MACHINE_PASSWORD}
    openstack server rebuild mira006 --image 2018-11-29-mira006-snap --password ${MACHINE_PASSWORD}
}

function start_virtual_machine() {
    openstack server start $1
}

function check_virtual_machine_network() {
    ping -c 1 $1
    PING_RESULT=$?
}

# Turn off the virtual machine
LEN=${#MACHINE_LIST[@]}
for ((i=0; i<${LEN}; i++))
do
    while :
    do
        turn_off_the_virtual_machine ${MACHINE_LIST[${i}]}
        check_virtual_machine_status ${MACHINE_LIST[${i}]}
        if [ "${RESULT}" = "SHUTOFF" ]; then
            break
        fi
    done
done
# Rebuild virtual machine
rebuild_virtual_machine
# Check that the virtual machine is rebuilt
for ((i=0; i<${LEN}; i++))
do
    while :
    do
        check_virtual_machine_status ${MACHINE_LIST[${i}]}
        if [ "${RESULT}" = "SHUTOFF" ]; then
            break
        fi
    done
done
# Start virtual machine
for ((i=0; i<${LEN}; i++))
do
    while :
    do
        start_virtual_machine ${MACHINE_LIST[${i}]}
        while :
        do
            check_virtual_machine_network ${MACHINE_IP[${i}]}
            echo ${PING_RESULT}
            if [ "${PING_RESULT}" = "0" ]; then
                break 2
            else
                break 1
            fi
        done
    done
done

sleep 300

