# -*- coding:utf-8 -*-
#!/usr/bin/python

from email.mime.text import MIMEText
from bottle import template
import requests
import smtplib
import time
import json
import re


CEPH_TEST_DETAIL_REPORT = """
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta httfrom commands import *p-equiv="Content-Type" content="text/html; charset=UTF-8">
<style type="text/css">
    table.gridtable {
        font-family:Verdana,Helvetica,sans serif;
        font-size:12px;
        color:#333333;
        border-width: 1px;
        border-color: #666666;
        border-collapse: collapse;
    }
    table.gridtable tr th {
        font-family:Verdana,Helvetica,sans serif;
        font-size:12px;
        border-width: 1px;
        padding: 2px;
        border-style: solid;
        border-color: #666666;
        background-color: #3399ff;
    }
    table.gridtable td {
        font-family:Verdana,Helvetica,sans serif;
        font-size:12px;
        border-width: 1px;
        padding: 2px;
        border-style: solid;
        border-color: #666666;
        background-color: #ffffff;
    }
    table.summarytable {
        font-family:Verdana,Helvetica,sans serif;
        font-size:12px;
        color:#333333;
        border-width: 1px;
        border-color: #666666;
        border-collapse: collapse;
    }
    .special{
        font-family:Verdana,Helvetica,sans serif;
        font-size: 14px;
        color:black;
    }
    .text{
        font-family:Verdana,Helvetica,sans serif;
        font-size: 12px;
        color:black;
        margin-left: 15px;
    }
    body {font-family:Verdana,Helvetica,sans serif;
          font-size:12px;
          color:black;
    }
</style>

<title>JOB REPORT</title>
</head>
<body>
<p class="text" style="margin-left:0px">
Dear ALL,
<br/>
<br/>

<tr>
Please find the CICD pipeline report for this build below: {{product_version}}
</tr>

</p><br/>

<li><b>Deployment</b></li><br/><br/>
<p style="margin-left: 15px">
 <table>
 % for URL in deployments:
 <tr><td>URL: </td><td>{{URL}}<td></tr>
 % end
 </table>
</p><br/><br/>

             <li><b>Teuthology Automation Test Summary</b></li><br/><br/>
             <p style="margin-left: 15px">
             <table class="gridtable">
                <tr>
                     <th style="font-weight:bold">Suite ID</th>
                     <th style="font-weight:bold">Suite</th>
                     <th style="font-weight:bold">Pass</th>
                     <th style="font-weight:bold">Fail</th>
                     <th style="font-weight:bold">Unknown</th>
                     <th style="font-weight:bold">logs</th>
                 </tr>
                 % for i in range(len(result_items)):
                 <tr>
                     <td>{{i+1}}</td>
                     <td>{{result_items[i][0]}}</td>
                     <td>{{result_items[i][1]}}</td>
                     <td>{{result_items[i][2]}}</td>
                     <td>{{result_items[i][3]}}</td>
                     <td>{{result_items[i][4]}}</td>
                 </tr>
                 %end
             </table>
             </p>
             </br>
             </br>

             <li><b>Teuthology Test Report</b></li><br/><br/>
             <p style="margin-left: 15px">
             <table class="gridtable">
                <tr>
                     <th style="font-weight:bold">Report ID</th>
                     <th style="font-weight:bold">Test items</th>
                     <th style="font-weight:bold">Result</th>
                     <th style="font-weight:bold">log</th>
                 </tr>
                 % for i in range(len(report_items)):
                 <tr>
                     <td>{{i+1}}</td>
                     <td>{{report_items[i][0]}}</td>
                     <td>{{report_items[i][1]}}</td>
                     <td>{{report_items[i][2]}}</td>
                 </tr>
                 %end
             </table>
             </p>
             </br>
             </br>

             <li><b>Daily Build Location:</b></li><br/>
             <p class="text">{{build_location}}</p></br>

             <li><b>New Patch List:</b></li><br/>
             <p class="text">
             % for new_patch in new_patch_list:
                 <pre>{{new_patch}}</pre><br/>
             % end
             </p>
             </br>

<p><font color="gray" size="2px">
Best Regards,<br/>
CloudTest Team<br/>
</font></p>

</body>
</html>

 """

def filled_email_template(email_template, deployments, teuthology_result, report_result, product_version, sds_pkg_url, new_patch_list):
	html = template(email_template, deployments=[(deployments)], product_version=product_version, result_items=teuthology_result, report_items=report_result, build_location=sds_pkg_url + product_version, new_patch_list=[new_patch_list])
	return html

def email_results(subject, from_, to, body):
	msg = MIMEText(body, _subtype='html', _charset='utf-8')
	msg['Subject'] = subject
	msg['From'] = from_
	msg['To'] = to
	smtp = smtplib.SMTP('localhost')
	smtp.sendmail(msg['From'], msg['To'].split(','), msg.as_string())
	smtp.quit()

def get_teuthology_result(url, log_url):
	while True:
		r = requests.get(url)
        	#print r.text
		time.sleep(60)
		s = json.loads(r.text)
		if int(s["results"]["running"]) == 0 and int(s["results"]["waiting"]) ==0 and int(s["results"]["queued"]) ==0:
			break
	result = json.loads(r.text)
	unknown = int(result["results"]["total"]) - int(result["results"]["pass"]) - int(result["results"]["fail"])
	email_items = [(result["name"], result["results"]["pass"], result["results"]["fail"], unknown, log_url)]
	return email_items

def get_teuthology_report_result(url, job_list):
	r = requests.get(url)
	s = json.loads(r.text)
	email_report_items = []
	for index, value in enumerate(s["jobs"]):
		if value["status"] == "fail":
			email_report_items.append((job_list[index], value["status"], value["log_href"]))
	return email_report_items

def get_sds_build_info(url, data_time):
	r = requests.get(url)
	pattern = "ThinkCloud-SDS-2.0.2-daily_" + data_time + "_[0-9]*\.tar\.gz"
	match_obj = re.findall(pattern, r.text, flags=0)
	if match_obj:
		return match_obj[0]
	else:
		return match_obj

def get_sds_new_patch_list(url):
	r = requests.get(url)
	return r.text

if __name__ == '__main__':
	data_time = time.strftime("%Y%m%d", time.localtime())
	paddles_rbd_url = "http://10.121.8.93:8080/runs/" + data_time + "-3.0-RBD"
	#paddles_rados_url = "http://10.121.8.93:8080/runs/" + data_time + "-3.0-RADOS"
	#paddles_ceph_test_url = "http://10.121.8.93:8080/runs/" + data_time + "-3.0-CEPH_TEST"
	rbd_log_url = "http://10.121.8.93/" + data_time + "-3.0-RBD"
	#rados_log_url = "http://10.121.8.93/" + data_time + "-3.0-RADOS"
	#ceph_test_log_url = "http://10.121.8.93/" + data_time + "-3.0-CEPH_TEST"
	sds_pkg_url = "http://10.120.16.212/build/ThinkCloud-SDS/master/"
	sds_controller_url = "http://10.121.8.100"

	sds_build_pkg_name = get_sds_build_info(sds_pkg_url, data_time)
	sds_new_patch_list = get_sds_new_patch_list(sds_pkg_url + "latest_changes.txt")
	rbd_result_items = get_teuthology_result(paddles_rbd_url, rbd_log_url)
	#rados_result_items = get_teuthology_result(paddles_rados_url, rados_log_url)
	#ceph_test_result_items = get_teuthology_result(paddles_ceph_test_url, ceph_test_log_url)
	#teuthology_result_items = rbd_result_items + rados_result_items + ceph_test_result_items
	teuthology_result_items = rbd_result_items
	rbd_job_list = ["cli_generic", "diff_continuous", "diff", "import_export", "issue-20295", "journal", "merge_diff", "notify_master", "notify_slave", "permissions", "read-flags", "smalliobench", "test_admin_socket", "test_librbd_api", "test_librbd_python", "test_librbd", "test_lock_fence", "test_rbdmap_RBDMAPFILE", "test_rbd_mirror", "verify_pool"]
	#rados_job_list = ["load-gen-big", "load-gen-mix", "load-gen-mix-small-long", "load-gen-mix-small", "load-gen-mostlyread", "stress_watch", "test_cache_pool", "test_pool_quota", "test_python", "test_rados_timeouts", "test_rados_tool", "test_tmap_to_omap", "test-upgrade-v11.0.0", "test"]
	#ceph_test_job_list = ["ceph_omapbench", "ceph_test_cls_lock", "ceph_test_cls_rgw", "ceph_test_mon_msg", "ceph_test_rados_api_cmd", "ceph_test_rados_api_nlist", "ceph_test_rados_striper_api_io", "ceph_perf_local", "ceph_test_cls_log", "ceph_test_cls_statelog", "ceph_test_msgr", "ceph_test_rados_api_c_read_operations", "ceph_test_rados_api_pool", "ceph_test_rados_watch_notify", "ceph_scratchtool", "ceph_test_cls_numops", "ceph_test_cls_version", "ceph_test_object_map", "ceph_test_rados_api_c_write_operations", "ceph_test_rados_delete_pools_parallel", "ceph_test_snap_mapper", "ceph_test_async_driver", "ceph_test_cls_rbd", "ceph_test_filejournal", "ceph_test_objectstore", "ceph_test_rados_api_list", "ceph_test_rados_list_parallel", "ceph_test_stress_watch", "ceph_test_cls_hello", "ceph_test_cls_refcount", "ceph_test_filestore", "ceph_test_rados_api_aio", "ceph_test_rados_api_lock", "ceph_test_rados_open_pools_parallel", "ceph_tpbench", "ceph_test_cls_journal", "ceph_test_cls_replica_log", "ceph_test_keyvaluedb", "ceph_test_rados_api_cls", "ceph_test_rados_api_misc", "ceph_test_rados_striper_api_aio", "ceph_test_rados_api_io", "ceph_test_rados_api_snapshots", "ceph_test_rados_api_stat", "ceph_test_rados_api_tier", "ceph_test_rados_api_tmap_migrate", "ceph_test_rados_api_watch_notify", "ceph_test_rbd_mirror"]
        rbd_result_report_items = get_teuthology_report_result(paddles_rbd_url, rbd_job_list)
        #rados_result_report_items = get_teuthology_report_result(paddles_rados_url, rados_job_list)
        #ceph_test_result_report_items = get_teuthology_report_result(paddles_ceph_test_url, ceph_test_job_list)
	#teuthology_result_report_items = rbd_result_report_items + rados_result_report_items + ceph_test_result_report_items
	teuthology_result_report_items = rbd_result_report_items
        

	email_body = filled_email_template(CEPH_TEST_DETAIL_REPORT, sds_controller_url, teuthology_result_items, teuthology_result_report_items, sds_build_pkg_name, sds_pkg_url, sds_new_patch_list)
	email_results(subject="[Teuthology]  ThinkCloud Storage 3.0 centos7.5 daily build release", from_="yujiang2@lenovo.com", to="yujiang2@lenovo.com", body=email_body)
	#email_results(subject="[Teuthology]  ThinkCloud-SDS-3.0-daily Test Report", from_="yujiang2@lenovo.com", to="yujiang2@lenovo.com,sunlei5@lenovo.com,zhangzz6@lenovo.com,zhangyil@lenovo.com,zhouyf6@lenovo.com,chenjing22@lenovo.com,houtf1@lenovo.com,renyb2@lenovo.com,magf@lenovo.com,cloudtester2@lenovo.com,houmx1@lenovo.com,xuhe4@lenovo.com,xiegang2@lenovo.com,wugang3@lenovo.com,liujun8@lenovo.com,cuixf1@lenovo.com,lihong5@lenovo.com,sunxw3@lenovo.com,wangqh8@lenovo.com", body=email_body)
