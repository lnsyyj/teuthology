#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pymysql
import time
import re
import os
import datetime
import requests
import json
from datetime import timedelta

mysql_ip = "10.121.9.23"
mysql_account = "root"
mysql_password = "1234567890"
mysql_db_name = "ceph"
mysql_table_name = "teuthology_statistics"

sds_version = "NAS"


def mariadb_connect_test():
    db = pymysql.connect(mysql_ip, mysql_account, mysql_password, mysql_db_name)
    cursor = db.cursor()
    cursor.execute("SELECT VERSION()")
    data = cursor.fetchone()
    print "Database version : %s " % data
    db.close()

def get_teuthology_result(url, data_time):
    r = requests.get(url)
    result = json.loads(r.text)
    unknown = int(result["results"]["total"]) - int(result["results"]["pass"]) - int(result["results"]["fail"])
    items = [(data_time ,result["results"]["pass"], result["results"]["fail"], unknown, result["name"], sds_version)]
    return items

def batch_insertion(table):
    conn = pymysql.connect(mysql_ip, mysql_account, mysql_password, mysql_db_name)
    cur = conn.cursor()
    for data in table:
        print data
        cur.execute("INSERT INTO teuthology_statistics(id, datetime, pass, fail, unknown, suite, sdsversion) VALUES(NULL, '%s', '%d', '%d', '%d', '%s', '%s')" % (data[0], int(data[1]), int(data[2]), int(data[3]), data[4], data[5]))
    conn.commit()
    cur.close()
    conn.close()

if __name__ == '__main__':
    #data_time = time.strftime("%Y%m%d", time.localtime())
    data_time = (datetime.datetime.now()+datetime.timedelta(days=-1)).strftime("%Y%m%d")

    paddles_rbd_url = "http://10.121.8.93:8080/runs/" + data_time + "-" + sds_version + "-RBD"
    paddles_rados_url = "http://10.121.8.93:8080/runs/" + data_time + "-" + sds_version + "-RADOS"
    paddles_ceph_test_url = "http://10.121.8.93:8080/runs/" + data_time + "-" + sds_version + "-CEPH_TEST"
    paddles_fs_url = "http://10.121.8.93:8080/runs/" + data_time + "-" + sds_version + "-FS"

    rbd_result_items = get_teuthology_result(paddles_rbd_url, data_time)
    rados_result_items = get_teuthology_result(paddles_rados_url, data_time)
    ceph_test_result_items = get_teuthology_result(paddles_ceph_test_url, data_time)
    fs_result_items = get_teuthology_result(paddles_fs_url, data_time)

    teuthology_result_items = rbd_result_items + rados_result_items + ceph_test_result_items + fs_result_items
    batch_insertion(teuthology_result_items)

    #mariadb_connect_test()
