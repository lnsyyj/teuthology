#!/bin/bash
#set -x

COPY_SDS_DEPLOY_SHELL_NODE="192.168.0.13"
COPY_SSH_RSA_PUB_NODE=(192.168.0.13 192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)
TEUTHOLOGY_INSTALL_RPM_CEPH_NODE=(192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)
CRUSHMAP_CEPH_NODE="192.168.0.17"
TEUTHOLOGY_NODE="192.168.0.14"

COPY_LICENSE_FILE_NAME="ThinkCloud_Storage_license_trial_2018-12-03.zip"
COPY_SDS_DEPLOY_SHELL_NAME="teuthology-deploy-sds.sh"

SSH_KNOWN_HOSTS_PATH="/root/.ssh/known_hosts"
FILE_DIRECTORY="/home/yujiang/"
MACHINE_PASSWORD="yujiang2"

function copy_ssh_rsa_pub() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
        do
                expect -c "
                set timeout 2000
                spawn ssh-copy-id root@${data}
                expect {
                        \"*Are you sure you want to continue connecting (yes/no)*\" { send \"yes\r\";exp_continue }
                        \"*root@192.168.* password:*\" { send \"${MACHINE_PASSWORD}\r\";exp_continue }
                }
                expect eof
                "
        done
}

function copy_shell_and_license_file_to_controller() {
        scp  ${FILE_DIRECTORY}${COPY_SDS_DEPLOY_SHELL_NAME}  ${FILE_DIRECTORY}${COPY_LICENSE_FILE_NAME} root@${COPY_SDS_DEPLOY_SHELL_NODE}:/root
}

function delete_ssh_known_hosts() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
	do
		sed -i "/.*${data}.*/d" ${SSH_KNOWN_HOSTS_PATH}
	done
}

function sds_install_pkg() {
        ssh "root@${COPY_SDS_DEPLOY_SHELL_NODE}" "/root/${COPY_SDS_DEPLOY_SHELL_NAME}"
}

function remote_stop_sds_service() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
        do
                ssh "root@${data}" "systemctl stop sds-agent.service ; systemctl disable sds-agent.service"
                ssh "root@${data}" "ps -ef | grep sds"
        done
}

function remote_modify_crushmap_ruleid() {
        ssh "root@${CRUSHMAP_CEPH_NODE}" "ceph osd getcrushmap -o crush.map; crushtool -d crush.map > crush.txt; cat crush.txt; sed -i \"s/\(\ *ruleset\).*/\1\ 0/g\" crush.txt; sed -i \"s/\(root\)\ hdd-default\(\ {\)/\1\ default\2/g\" crush.txt; sed -i \"s/\(\ *step\ take\ \)hdd-default/\1default/g\" crush.txt;crushtool -c crush.txt -o crush2.map; ceph osd setcrushmap -i crush2.map"
}

function remote_modify_dns() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
        do
                ssh "root@${data}" "echo \"nameserver 10.96.1.18\" > /etc/resolv.conf"
        done
}

#CEPH_RPMS=(rbd-fuse-10.2.7-0.el7.x86_64.rpm ceph-test-10.2.7-0.el7.x86_64.rpm)
#CEPH_RPMS=(rbd-fuse-10.2.7-0.el7.x86_64.rpm ceph-test-10.2.7.3.0.4-0.el7.x86_64.rpm)
CEPH_RPMS=(rbd-fuse-10.2.7.3.1.1-0.el7.x86_64.rpm ceph-test-10.2.7.3.1.7-0.el7.x86_64.rpm)
function remote_install_ceph_pkg() {
	for data in ${TEUTHOLOGY_INSTALL_RPM_CEPH_NODE[@]}
        do
		for rpm_name in ${CEPH_RPMS[@]}
		do
			scp ${FILE_DIRECTORY}${rpm_name} "root@${data}:/root"
			ssh "root@${data}" "rpm -Uivh ${rpm_name} --nodeps --force"
		done
                scp ${FILE_DIRECTORY}ceph-10.2.7.tar.gz ${FILE_DIRECTORY}clear_pools.py "root@${data}:/root"
                ssh "root@${data}" "tar zxf ceph-10.2.7.tar.gz"
        done
}

function remote_install_teuthology_dependency() {
	for data in ${TEUTHOLOGY_INSTALL_RPM_CEPH_NODE[@]}
        do
                ssh "root@${data}" "yum install -y wget expect curl qemu-kvm git bc rsync attr java-1.7.0-openjdk java-1.7.0-openjdk-devel junit fuse bonnie++ libxslt xmlstarlet iozone attr --nogpgcheck"
                #ssh "root@${data}" "wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;rpm -Uvh epel-release*rpm;yum install -y libxslt --nogpgcheck"
                #ssh "root@${data}" "curl \"https://bootstrap.pypa.io/get-pip.py\" -o \"get-pip.py\";python get-pip.py;python -m pip install -U pip;pip install --upgrade setuptools;pip install paramiko==2.3.0 nose==1.3.7 --timeout 6000"
        done
}

function remote_teuthology_add_schedule() {
        ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/ceph_test_rpm_yaml/schedule_ceph_test.sh"
	ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/rados_test_yaml/schedule_rados.sh"
	ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/rbd_test_yaml/schedule_rbd.sh"
}

delete_ssh_known_hosts
copy_ssh_rsa_pub
copy_shell_and_license_file_to_controller
sds_install_pkg
remote_modify_crushmap_ruleid

remote_modify_dns
remote_install_teuthology_dependency
remote_install_ceph_pkg
remote_stop_sds_service
remote_teuthology_add_schedule
