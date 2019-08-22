#!/bin/bash
set -x

DATA=$(date +%Y%m%d)
SUITE="NAS-CEPH_UNITTEST"

FILE_LIST=(unittest_addrs.yaml unittest_admin_socket.yaml unittest_alloc.yaml unittest_alloc_bench.yaml unittest_any.yaml unittest_arch.yaml unittest_async_completion.yaml unittest_async_shared_mutex.yaml unittest_auth.yaml unittest_back_trace.yaml unittest_base64.yaml unittest_bit_vector.yaml unittest_bloom_filter.yaml unittest_bluefs.yaml unittest_bluestore_types.yaml unittest_bounded_key_counter.yaml unittest_bufferlist.yaml unittest_ceph_argparse.yaml unittest_ceph_compatset.yaml unittest_ceph_crypto.yaml unittest_chain_xattr.yaml unittest_config.yaml unittest_confutils.yaml unittest_context.yaml unittest_convenience.yaml unittest_crc32c.yaml unittest_crush.yaml unittest_crush_wrapper.yaml unittest_crypto.yaml unittest_crypto_init.yaml unittest_daemon_config.yaml unittest_denc.yaml unittest_dns_resolve.yaml unittest_ecbackend.yaml unittest_ec_transaction.yaml unittest_encoding.yaml unittest_erasure_code.yaml unittest_erasure_code_example.yaml unittest_erasure_code_isa.yaml unittest_erasure_code_jerasure.yaml unittest_erasure_code_shec.yaml unittest_erasure_code_shec_all.yaml unittest_erasure_code_shec_arguments.yaml unittest_erasure_code_shec_thread.yaml unittest_escape.yaml unittest_extent_cache.yaml unittest_fastbmap_allocator.yaml unittest_features.yaml unittest_formatter.yaml unittest_gather.yaml unittest_heartbeatmap.yaml unittest_histogram.yaml unittest_hitset.yaml unittest_hobject.yaml unittest_hostname.yaml unittest_http_manager.yaml unittest_interval_map.yaml unittest_interval_set.yaml unittest_ipaddr.yaml unittest_iso_8601.yaml unittest_json_formattable.yaml unittest_json_formatter.yaml unittest_lfnindex.yaml unittest_libcephfs_config.yaml unittest_librados.yaml unittest_librados_config.yaml unittest_lockdep.yaml unittest_log.yaml unittest_lru.yaml unittest_mclock_client_queue.yaml unittest_mclock_op_class_queue.yaml unittest_mclock_priority_queue.yaml unittest_mds_authcap.yaml unittest_mds_sessionfilter.yaml unittest_mds_types.yaml unittest_mempool.yaml unittest_memstore_clone.yaml unittest_mime.yaml unittest_mon_moncap.yaml unittest_mon_montypes.yaml unittest_mon_pgmap.yaml unittest_mutex.yaml unittest_mutex_debug.yaml unittest_numa.yaml unittest_osdmap.yaml unittest_osd_osdcap.yaml unittest_osdscrub.yaml unittest_osd_types.yaml unittest_pageset.yaml unittest_perf_counters.yaml unittest_perf_histogram.yaml unittest_pglog.yaml unittest_pg_transaction.yaml unittest_prioritized_queue.yaml unittest_random.yaml unittest_rbd_replay.yaml unittest_readahead.yaml unittest_rgw_amqp.yaml unittest_rgw_bencode.yaml unittest_rgw_crypto.yaml unittest_rgw_dmclock_scheduler.yaml unittest_rgw_iam_policy.yaml unittest_rgw_period_history.yaml unittest_rgw_putobj.yaml unittest_rgw_reshard_wait.yaml unittest_rgw_string.yaml unittest_rgw_xml.yaml unittest_rocksdb_option.yaml unittest_run_cmd.yaml unittest_safe_io.yaml unittest_shared_cache.yaml unittest_sharedptr_registry.yaml unittest_shunique_lock.yaml unittest_signals.yaml unittest_simple_spin.yaml unittest_sloppy_crc_map.yaml unittest_static_ptr.yaml unittest_striper.yaml unittest_str_list.yaml unittest_str_map.yaml unittest_strtol.yaml unittest_subprocess.yaml unittest_tableformatter.yaml unittest_texttable.yaml unittest_throttle.yaml unittest_time.yaml unittest_transaction.yaml unittest_url_escape.yaml unittest_utf8.yaml unittest_util.yaml unittest_weighted_priority_queue.yaml unittest_workqueue.yaml unittest_xlist.yaml unittest_xmlformatter.yaml)

function activate() {
        source /home/teuthworker/src/teuthology_master/virtualenv/bin/activate
}

activate
pushd /home/teuthology/src/teuthology_master/14_unittest_test_yaml/

for file_name in ${FILE_LIST[@]}
do
        teuthology-schedule --name "${DATA}-${SUITE}" ${file_name} --worker multi
done

#teuthology-schedule --name "${DATA}-${SUITE}" verify_pool.yaml

popd
