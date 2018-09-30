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
                     <th style="font-weight:bold">Suite</th>
                     <th style="font-weight:bold">Pass</th>
                     <th style="font-weight:bold">Fail</th>
                     <th style="font-weight:bold">Unknown</th>
                     <th style="font-weight:bold">logs</th>
                 </tr>
                 % for i in range(len(items)):
                 <tr>
                     <td>{{items[i][0]}}</td>
                     <td>{{items[i][1]}}</td>
                     <td>{{items[i][2]}}</td>
                     <td>{{items[i][3]}}</td>
                     <td>{{items[i][4]}}</td>
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

def filled_email_template(email_template, deployments, teuthology_result, product_version, sds_pkg_url, new_patch_list):
	html = template(email_template, deployments=[(deployments)], product_version=product_version, items=teuthology_result, build_location=sds_pkg_url + product_version, new_patch_list=[new_patch_list])
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
		time.sleep(5)
		s = json.loads(r.text)
		if int(s["results"]["running"]) == 0 and int(s["results"]["waiting"]) ==0 and int(s["results"]["queued"]) ==0:
			break
	result = json.loads(r.text)
	unknown = int(result["results"]["total"]) - int(result["results"]["pass"]) - int(result["results"]["fail"])
	email_items = [(result["name"], result["results"]["pass"], result["results"]["fail"], unknown, log_url)]
	return email_items

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
	paddles_rbd_url = "http://10.121.8.93:8080/runs/" + data_time + "-RBD"
	paddles_rados_url = "http://10.121.8.93:8080/runs/" + data_time + "-RADOS"
	rbd_log_url = "http://10.121.8.93/" + data_time + "-RBD"
	rados_log_url = "http://10.121.8.93/" + data_time + "-RADOS"
	sds_pkg_url = "http://10.120.16.212/build/ThinkCloud-SDS/tcs_nfvi_centos7.5/"
	sds_controller_url = "http://10.121.8.95"

	sds_build_pkg_name = get_sds_build_info(sds_pkg_url, data_time)
	sds_new_patch_list = get_sds_new_patch_list(sds_pkg_url + "latest_changes.txt")
	teuthology_rbd_result = get_teuthology_result(paddles_rbd_url, rbd_log_url)
	teuthology_rados_result = get_teuthology_result(paddles_rados_url, rados_log_url)
	teuthology_result = teuthology_rbd_result + teuthology_rados_result

	email_body = filled_email_template(CEPH_TEST_DETAIL_REPORT, sds_controller_url, teuthology_result, sds_build_pkg_name, sds_pkg_url, sds_new_patch_list)
	email_results(subject="[Teuthology]  ThinkCloud Storage TCS tcs_nfvi_centos7.5 daily build release", from_="yujiang2@lenovo.com", to="yujiang2@lenovo.com,sunlei5@lenovo.com,zhangzz6@lenovo.com,zhangyil@lenovo.com,zhouyf6@lenovo.com,chenjing22@lenovo.com,houtf1@lenovo.com,renyb2@lenovo.com,magf@lenovo.com,cloudtester2@lenovo.com,houmx1@lenovo.com,xuhe4@lenovo.com,xiegang2@lenovo.com,wugang3@lenovo.com", body=email_body)
