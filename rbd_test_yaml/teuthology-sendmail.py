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
                 % for casename, passed, fail, unknown, logs in items:
                 <tr>
                     <td>{{casename}}</td>
                     <td>{{passed}}</td>
                     <td>{{fail}}</td>
                     <td>{{unknown}}</td>
                     <td>{{logs}}</td>
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

def filled_email_template(email_template, deployments, teuthology_result, log_url, product_version, sds_pkg_url, new_patch_list):
	s = json.loads(teuthology_result)
	# casename, total, pass, running, fail, unknown, waiting, queued, dead, info, logs 
	# email_items = [(s["name"], s["results"]["total"], s["results"]["pass"], s["results"]["running"], s["results"]["fail"], s["results"]["unknown"], s["results"]["waiting"], s["results"]["queued"], s["results"]["dead"], log_url)]
	unknown = int(s["results"]["total"]) - int(s["results"]["pass"]) - int(s["results"]["fail"])
	email_items = [(s["name"], s["results"]["pass"], s["results"]["fail"], unknown, log_url)]
	html = template(email_template, deployments=[(deployments)], product_version=product_version, items=email_items, build_location=sds_pkg_url + product_version, new_patch_list=[new_patch_list])
	return html

def email_results(subject, from_, to, body):
	msg = MIMEText(body, _subtype='html', _charset='utf-8')
	msg['Subject'] = subject
	msg['From'] = from_
	msg['To'] = to
	smtp = smtplib.SMTP('localhost')
	smtp.sendmail(msg['From'], msg['To'].split(','), msg.as_string())
	smtp.quit()

def get_teuthology_result(url):
	while True:
		r = requests.get(url)
		time.sleep(5)
		s = json.loads(r.text)
		if int(s["results"]["running"]) == 0 and int(s["results"]["waiting"]) ==0 and int(s["results"]["queued"]) ==0:
			break
	return r.text

def get_sds_build_info(url, data_time):
	r = requests.get(url)
	pattern = "deployment-standalone-daily_" + data_time + "_[0-9]*\.tar\.gz"
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
	paddles_url = "http://10.100.46.205:8080/runs/" + data_time + "-RBD"
	log_url = "http://10.100.46.205/" + data_time + "-RBD"
	sds_pkg_url = "http://10.120.16.212/build/ThinkCloud-SDS/tcs_nfvi_centos7.5/"
	sds_controller_url = "http://10.100.47.169"

	sds_build_pkg_name = get_sds_build_info(sds_pkg_url, data_time)
	sds_new_patch_list = get_sds_new_patch_list(sds_pkg_url + "latest_changes.txt")

	teuthology_result = get_teuthology_result(paddles_url)
	print teuthology_result
	email_body = filled_email_template(CEPH_TEST_DETAIL_REPORT, sds_controller_url, teuthology_result, log_url, sds_build_pkg_name, sds_pkg_url, sds_new_patch_list)
	email_results(subject="[Teuthology]  ThinkCloud Storage TCS tcs_nfvi_centos7.5 daily build release", from_="yujiang@lenovo.com", to="yujiang2@lenovo.com", body=email_body)
