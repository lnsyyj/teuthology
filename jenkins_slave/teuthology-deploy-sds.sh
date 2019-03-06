#!/bin/bash

IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6 | awk '{print $2}' | tr -d "addr:"`
HOSTNAME=`hostname -f`

CEPH_CONTROLLER_IP="192.168.0.13"
SDS_PKG_URL="http://10.120.16.212/build/ThinkCloud-SDS/release-2.0/"
SDS_TAR_PKG=$(curl http://10.120.16.212/build/ThinkCloud-SDS/release-2.0/ | grep ThinkCloud-SDS-2.0.2-daily_ | tail -1 | sed 's/.*\(ThinkCloud-SDS-2.0.2-daily_[0-9]*_[0-9]*.tar.gz\).*/\1/')
SDS_PKG_DATE=$(echo ${SDS_TAR_PKG} | sed 's/.*ThinkCloud-SDS-2.0.2-daily_\([0-9]*_[0-9]*\).tar.gz.*/\1/')
#SDS_TAR_PKG="deployment-standalone-daily_20180814_89.tar.gz"

CEPH_NODE_HOST_USER="root"
CEPH_NODE_HOST_PASSWORD="yujiang2"

CEPH_NODE_NAME=(plana003 plana004 plana005 plana006)
CEPH_PUBLIC_IP=(192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)
CEPH_CLUSTER_IP=(192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)
CEPH_MANAGER_IP=(192.168.0.17 192.168.0.25 192.168.0.15 192.168.0.24)


function install_dependent(){
	sudo yum install -y wget expect curl
        curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
        python get-pip.py
        python -m pip install -U pip
        pip install --upgrade setuptools
}

function modify_hosts_file(){
	if ! grep -q "${IP}.*api.inte.lenovo.com" /etc/hosts; then
		echo "${IP}	api.inte.lenovo.com" >> /etc/hosts
	fi
}

function modify_dns(){
	if ! grep -q "nameserver.*10.96.1.18" /etc/resolv.conf; then
		echo "nameserver 10.96.1.18" > /etc/resolv.conf
	fi
}

function download_sds(){
	wget ${SDS_PKG_URL}${SDS_TAR_PKG}  > /dev/null 2>&1
}

function uzip_and_install_sds(){
	tar zxvf ${SDS_TAR_PKG}
	pushd deployment
	
	expect -c "
	set timeout 2000
	spawn ./standalone-setup.sh install -s
	expect {
		\"*Please enter the mysql root password*\" { send \"SDS_Passw0rd\r\";exp_continue }
		\"*Please enter the zabbix db user zabbix* password\" { send \"SDS_Passw0rd\r\";exp_continue }
		\"*Please enter the keystone db user keystone* password*\" { send \"SDS_Passw0rd\r\";exp_continue }
		\"*Please enter the system user admin* password*\" { send \"Admin_123456\r\";exp_continue }
		\"*Please enter the Rabbit user storage* password*\" { send \"SDS_Passw0rd\r\";exp_continue }
		\"*Please enter the storagemgmt db user storage* password*\" { send \"SDS_Passw0rd\r\" }
                \"*Is this ok*\" { send \"y\r\" }
	}
	expect eof
	"
	popd
}

function put_license(){
	LOCAL_PATH=`pwd`
	# TOKEN=`keystone token-get | grep "\ id" | awk '{print $4}'`
	# curl -H "LOG_USER: admin" -H "X-Auth-Token: ${TOKEN}" -H "Content-type:application/json"  -X GET http://localhost:9999/v1/license/
	# sleep 5
	source /root/localrc
	echo "${LOCAL_PATH}/ThinkCloud_Storage_license_trial_2018-12-03.zip"
	cephmgmtclient update-license -l "ThinkCloud_Storage_license_trial_2018-12-03.zip"
}

function create_ceph_cluster(){
	source /root/localrc
	cephmgmtclient create-cluster --name ceph-cluster-1 --addr vm
}

function add_host_to_cluster(){
	source /root/localrc
	LEN=${#CEPH_NODE_NAME[@]}
	for ((i=0; i<${LEN}; i++))
	do
		cephmgmtclient create-server --id 1 --name ${CEPH_NODE_NAME[${i}]} --publicip ${CEPH_PUBLIC_IP[${i}]} --clusterip ${CEPH_CLUSTER_IP[${i}]} --managerip ${CEPH_MANAGER_IP[${i}]}  --server_user ${CEPH_NODE_HOST_USER} --server_pass ${CEPH_NODE_HOST_PASSWORD} --rack_id 1
	done
}

function deploy_ceph_cluster(){
	source /root/localrc
	cephmgmtclient deploy-cluster 1
}

function deploy_ceph_config_zabbix(){
        source /root/localrc
        cephmgmtclient update-cluster-conf -c 1 -z ${CEPH_CONTROLLER_IP} -u admin -p zabbix -t 600 -r 10
}

STARTTIME=`date +'%Y-%m-%d %H:%M:%S'`

modify_hosts_file
modify_dns
install_dependent
download_sds
uzip_and_install_sds
sleep 5
put_license
sleep 5
create_ceph_cluster
sleep 5
add_host_to_cluster
sleep 1200
deploy_ceph_cluster
sleep 900
# deploy_ceph_config_zabbix
# sleep 5

ENDTIME=`date +'%Y-%m-%d %H:%M:%S'`
START_SECONDS=$(date --date="${STARTTIME}" +%s)
END_SECONDS=$(date --date="${ENDTIME}" +%s)
echo "本次运行时间： "$((END_SECONDS-START_SECONDS))"s"
