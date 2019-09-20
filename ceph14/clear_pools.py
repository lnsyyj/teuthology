#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import commands

retention_pool = ('cephfs_data', 'cephfs_metadata', '.rgw.root', 'default.rgw.control', 'default.rgw.meta', 'default.rgw.log')

def delete_all_test_pool():
  status,output = commands.getstatusoutput('rados lspools')
  arr = output.split('\n')
  for poolname in arr:
    poolname = poolname.strip()
    if poolname not in retention_pool:
      delete_pool_cmd = "ceph osd pool delete" + " " + poolname + " " + poolname + " " + "--yes-i-really-really-mean-it"
      print delete_pool_cmd
      commands.getstatusoutput(delete_pool_cmd)

def create_rbd_pool():
  commands.getstatusoutput('ceph osd pool create rbd 512')

if __name__=="__main__":
  delete_all_test_pool()
  create_rbd_pool()
