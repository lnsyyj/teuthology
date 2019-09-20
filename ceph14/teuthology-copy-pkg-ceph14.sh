#!/bin/bash
#set -x

COPY_SDS_DEPLOY_SHELL_NODE="192.168.0.13"
COPY_SSH_RSA_PUB_NODE=(192.168.0.13 192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)
TEUTHOLOGY_INSTALL_RPM_CEPH_NODE=(192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)
CRUSHMAP_CEPH_NODE="192.168.0.17"
TEUTHOLOGY_NODE="192.168.0.14"

COPY_LICENSE_FILE_NAME="ThinkCloud_Storage_license_trial_2018-12-03.zip"
COPY_SDS_DEPLOY_SHELL_NAME="teuthology-deploy-sds-ceph14.sh"

SSH_KNOWN_HOSTS_PATH="/root/.ssh/known_hosts"
FILE_DIRECTORY="/home/yujiang/ceph14/"
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
                ssh "root@${data}" "ps -ef | grep sds"
                ssh "root@${data}" "ps -ef | grep ceph"
                ssh "root@${data}" "systemctl stop sds-agent.service ; systemctl disable sds-agent.service"
                ssh "root@${data}" "ps -ef | grep sds"
        done
}

function remote_modify_crushmap_ruleid() {
        ssh "root@${CRUSHMAP_CEPH_NODE}" "ceph osd getcrushmap -o crush.map; crushtool -d crush.map > crush.txt; cat crush.txt; sed -i \"s/\(\ *id\) 1/\1\ 0/g\" crush.txt ; sed -i \"s/\(root\)\ hdd-default\(\ {\)/\1\ default\2/g\" crush.txt; sed -i \"s/\(\ *step\ take\ \)hdd-default/\1default/g\" crush.txt;crushtool -c crush.txt -o crush2.map; ceph osd setcrushmap -i crush2.map"
}

function remote_modify_dns() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
        do
                ssh "root@${data}" "echo \"nameserver 10.96.1.18\" > /etc/resolv.conf"
        done
}

#CEPH_RPMS=(rbd-fuse-10.2.7-0.el7.x86_64.rpm ceph-test-10.2.7-0.el7.x86_64.rpm)
#CEPH_RPMS=(rbd-fuse-12.2.8-0.el7.x86_64.rpm ceph-test-12.2.8.1.0.1-0.el7.centos.x86_64.rpm)
function remote_get_ceph_test_pkg() {
	#ssh "root@${COPY_SDS_DEPLOY_SHELL_NODE}" "tar zxvf /root/deployment/tools/InstallCeph-centos73.tar.gz -C /root"
	IIII=`ssh "root@${COPY_SDS_DEPLOY_SHELL_NODE}" "ls /root/InstallCeph-centos73/local_repo/ | grep ceph-test | awk '{print $9}'"`
	#scp "root@${COPY_SDS_DEPLOY_SHELL_NODE}:/root" ""
}

CEPH_RPMS=()
CEPH_SOURCE_PACKAGE="ceph-14.2.1.tar.gz"
function remote_install_ceph_pkg() {
	ssh "root@${COPY_SDS_DEPLOY_SHELL_NODE}" "tar zxvf /root/deployment/tools/InstallCeph-centos73.tar.gz -C /root"
	#CEPH_TEST_RPM_NAME=`ssh "root@${COPY_SDS_DEPLOY_SHELL_NODE}" "ls /root/InstallCeph-centos73/local_repo/ | grep ceph-test | awk '{print $9}'"`
	CEPH_TEST_RPM_NAME=`ssh "root@${COPY_SDS_DEPLOY_SHELL_NODE}" "ls /root/deployment/local_repo/packages/ | grep ceph-test | awk '{print $9}'"`
	#scp "root@${COPY_SDS_DEPLOY_SHELL_NODE}:/root/InstallCeph-centos73/local_repo/${CEPH_TEST_RPM_NAME}" "/home/yujiang"
	scp "root@${COPY_SDS_DEPLOY_SHELL_NODE}:/root/deployment/local_repo/packages/${CEPH_TEST_RPM_NAME}" "/home/yujiang/ceph14"
	CEPH_RPMS=("${CEPH_RPMS[@]}" "${CEPH_TEST_RPM_NAME}")

	for data in ${TEUTHOLOGY_INSTALL_RPM_CEPH_NODE[@]}
        do
		for rpm_name in ${CEPH_RPMS[@]}
		do
			scp ${FILE_DIRECTORY}${rpm_name} "root@${data}:/root"
			ssh "root@${data}" "rpm -Uivh ${rpm_name} --nodeps --force"
		done
                scp ${FILE_DIRECTORY}${CEPH_SOURCE_PACKAGE} ${FILE_DIRECTORY}clear_pools.py "root@${data}:/root"
                ssh "root@${data}" "tar zxf ${CEPH_SOURCE_PACKAGE}"
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
	ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/14_rados_test_yaml/schedule_rados.sh"
	ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/14_rbd_test_yaml/schedule_rbd.sh"
        ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/14_ceph_test_rpm_yaml/schedule_ceph_test.sh"
        ssh "root@${TEUTHOLOGY_NODE}" "/home/teuthology/src/teuthology_master/14_fs_test_yaml/schedule_fs.sh"
}

function create_cephfs() {
	ssh "root@${CRUSHMAP_CEPH_NODE}" "ceph osd pool create cephfs_data 128"
	ssh "root@${CRUSHMAP_CEPH_NODE}" "ceph osd pool create cephfs_metadata 128"
	ssh "root@${CRUSHMAP_CEPH_NODE}" "ceph fs new cephfs cephfs_metadata cephfs_data"
	ssh "root@${CRUSHMAP_CEPH_NODE}" "ceph fs ls"
}

MOUNT_POINT="/home/teuthology_cephfs_mount_point"
function create_dir() {
	for data in ${TEUTHOLOGY_INSTALL_RPM_CEPH_NODE[@]}
	do
		echo ${data}
		ssh "root@${data}" "mkdir -p ${MOUNT_POINT}"
		ssh "root@${data}" "sudo ceph-fuse -m ${CRUSHMAP_CEPH_NODE}:6789 ${MOUNT_POINT}"
	done
	ssh "root@${CRUSHMAP_CEPH_NODE}" "cp /root/${CEPH_SOURCE_PACKAGE} ${MOUNT_POINT}"
	ssh "root@${CRUSHMAP_CEPH_NODE}" "tar zxf ${MOUNT_POINT}/${CEPH_SOURCE_PACKAGE} -C ${MOUNT_POINT}"
}

delete_ssh_known_hosts
copy_ssh_rsa_pub
copy_shell_and_license_file_to_controller
sds_install_pkg
remote_modify_crushmap_ruleid
sleep 300

remote_modify_dns
remote_install_teuthology_dependency
remote_install_ceph_pkg
remote_stop_sds_service
create_cephfs
sleep 300
create_dir
remote_teuthology_add_schedule
