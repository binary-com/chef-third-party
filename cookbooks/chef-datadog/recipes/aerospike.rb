include_recipe '::dd-agent'

# Monitor Aerospike
#
# Here is the description of acceptable attributes:
# node.datadog.aerospike = {
#   # instances - required: false
#   "instances" => [
#     {
#       # host - required: true  - string
#       "host" => "localhost",
#       # port - required: true  - integer
#       "port" => 3000,
#       # username - required: false  - string
#       "username" => nil,
#       # password - required: false  - string
#       "password" => nil,
#       # tls_name - required: false  - string
#       "tls_name" => nil,
#       # tls_config - required: false  - object
#       "tls_config" => {
#         "cafile" => "<CA_FILE>",
#         "certfile" => "<CERT_FILE>",
#         "keyfile" => "<KEY_FILE>",
#       },
#       # timeout - required: false  - number
#       "timeout" => 10,
#       # metrics - required: false  - array of string
#       "metrics" => [
#         "migrate_rx_objs",
#         "migrate_tx_objs",
#       ],
#       # namespaces - required: false  - array of string
#       "namespaces" => [
#         "example_namespace",
#         "another_example_namespace",
#       ],
#       # datacenters - required: false  - array of string
#       "datacenters" => [
#         "example_datacenter",
#         "another_example_datacenter",
#       ],
#       # namespace_metrics - required: false  - array of string
#       "namespace_metrics" => [
#         "free-pct-disk",
#         "free-pct-memory",
#         "evicted-objects",
#         "expired-objects",
#         "master-objects",
#         "migrate-rx-partitions-initial",
#         "migrate-rx-partitions-remaining",
#         "migrate-tx-partitions-initial",
#         "migrate-tx-partitions-remaining",
#       ],
#       # datacenter_metrics - required: false  - array of string
#       "datacenter_metrics" => [
#         "dc_rec_ship_attempts",
#         "dc_remote_ship_ok",
#         "dc_delete_ship_attempts",
#       ],
#       # tags - required: false  - array of string
#       "tags" => [
#         "<KEY_1>:<VALUE_1>",
#         "<KEY_2>:<VALUE_2>",
#       ],
#       # service - required: false  - string
#       "service" => nil,
#       # min_collection_interval - required: false  - number
#       "min_collection_interval" => 15,
#       # empty_default_hostname - required: false  - boolean
#       "empty_default_hostname" => false,
#     },
#   ],
#   # init_config - required: false
#   "init_config" => {
#     # mappings - required: true  - array of string
#     "mappings" => [
#       "basic_scans_failed",
#       "basic_scans_succeeded",
#       "batch_error",
#       "batch_index_initiate",
#       "batch_index_complete",
#       "batch_index_timeout",
#       "batch_index_error",
#       "batch_index_unused_buffers",
#       "batch_index_huge_buffers",
#       "batch_index_created_buffers",
#       "batch_index_destroyed_buffers",
#       "batch_initiate",
#       "batch_timeout",
#       "dlog_logged",
#       "dlog_overwritten_error",
#       "dlog_processed_link_down",
#       "dlog_processed_main",
#       "dlog_processed_replica",
#       "dlog_relogged",
#       "dlog_used_objects",
#       "early_tsvc_batch_sub_error",
#       "early_tsvc_client_error",
#       "early_tsvc_udf_sub_error",
#       "err_duplicate_proxy_request",
#       "err_out_of_space",
#       "err_recs_dropped",
#       "err_replica_non_null_node",
#       "err_replica_null_node",
#       "err_rw_cant_put_unique",
#       "err_rw_pending_limit",
#       "err_rw_request_not_found",
#       "err_storage_queue_full",
#       "err_sync_copy_null_master",
#       "err_sync_copy_null_node",
#       "err_tsvc_requests",
#       "err_tsvc_requests_timeout",
#       "err_write_fail_bin_exists",
#       "err_write_fail_bin_name",
#       "err_write_fail_bin_not_found",
#       "err_write_fail_forbidden",
#       "err_write_fail_generation",
#       "err_write_fail_generation_xdr",
#       "err_write_fail_incompatible_type",
#       "err_write_fail_key_exists",
#       "err_write_fail_key_mismatch",
#       "err_write_fail_not_found",
#       "err_write_fail_noxdr",
#       "err_write_fail_parameter",
#       "err_write_fail_prole_delete",
#       "err_write_fail_prole_generation",
#       "err_write_fail_prole_unknown",
#       "err_write_fail_record_too_big",
#       "err_write_fail_unknown",
#       "fabric_msgs_rcvd",
#       "fabric_msgs_sent",
#       "heartbeat_received_foreign",
#       "heartbeat_received_self",
#       "hotkeys_fetched",
#       "info_complete",
#       "local_recs_error",
#       "local_recs_fetch_avg_latency",
#       "local_recs_fetched",
#       "local_recs_notfound",
#       "migrate_msgs_recv",
#       "migrate_msgs_sent",
#       "migrate_num_incoming_accepted",
#       "migrate_num_incoming_refused",
#       "noship_recs_expired",
#       "noship_recs_hotkey",
#       "noship_recs_notmaster",
#       "noship_recs_uninitialized_destination",
#       "noship_recs_unknown_namespace",
#       "proxy_action",
#       "proxy_initiate",
#       "proxy_retry",
#       "proxy_retry_new_dest",
#       "proxy_retry_q_full",
#       "proxy_retry_same_dest",
#       "proxy_unproxy",
#       "query_abort",
#       "query_agg",
#       "query_agg_abort",
#       "query_agg_avg_rec_count",
#       "query_agg_err",
#       "query_agg_success",
#       "query_avg_rec_count",
#       "query_fail",
#       "query_long_queue_full",
#       "query_long_reqs",
#       "query_long_running",
#       "query_lookup_abort",
#       "query_lookup_avg_rec_count",
#       "query_lookup_err",
#       "query_lookups",
#       "query_lookup_success",
#       "query_reqs",
#       "query_short_queue_full",
#       "query_short_reqs",
#       "query_short_running",
#       "query_success",
#       "query_tracked",
#       "read_dup_prole",
#       "reaped_fds",
#       "rw_err_ack_badnode",
#       "rw_err_ack_internal",
#       "rw_err_ack_nomatch",
#       "rw_err_dup_cluster_key",
#       "rw_err_dup_internal",
#       "rw_err_dup_send",
#       "rw_err_write_cluster_key",
#       "rw_err_write_internal",
#       "rw_err_write_send",
#       "scans_active",
#       "sindex_gc_activity_dur",
#       "sindex_gc_garbage_cleaned",
#       "sindex_gc_garbage_found",
#       "sindex_gc_inactivity_dur",
#       "sindex_gc_list_creation_time",
#       "sindex_gc_list_deletion_time",
#       "sindex_gc_locktimedout",
#       "sindex_gc_objects_validated",
#       "sindex_ucgarbage_found",
#       "stat_cluster_key_err_ack_dup_trans_reenqueue",
#       "stat_cluster_key_err_ack_rw_trans_reenqueue",
#       "stat_cluster_key_partition_transaction_queue_count",
#       "stat_cluster_key_prole_retry",
#       "stat_cluster_key_regular_processed",
#       "stat_cluster_key_transaction_reenqueue",
#       "stat_cluster_key_trans_to_proxy_retry",
#       "stat_deleted_set_objects",
#       "stat_delete_success",
#       "stat_duplicate_operation",
#       "stat_evicted_objects",
#       "stat_expired_objects",
#       "stat_ldt_proxy",
#       "stat_nsup_deletes_not_shipped",
#       "stat_evicted_set_objects",
#       "stat_proxy_errs",
#       "stat_proxy_reqs",
#       "stat_proxy_reqs_xdr",
#       "stat_proxy_success",
#       "stat_read_errs_notfound",
#       "stat_read_errs_other",
#       "stat_read_reqs",
#       "stat_read_reqs_xdr",
#       "stat_read_success",
#       "stat_recs_inflight",
#       "stat_recs_linkdown_processed",
#       "stat_recs_logged",
#       "stat_recs_logged_master",
#       "stat_recs_outstanding",
#       "stat_recs_relogged",
#       "stat_recs_relogged_incoming",
#       "stat_recs_relogged_outgoing",
#       "stat_recs_replprocessed",
#       "stat_recs_shipped",
#       "stat_recs_shipped_binlevel",
#       "stat_recs_shipped_ok",
#       "stat_rw_timeout",
#       "stat_slow_trans_queue_batch_pop",
#       "stat_slow_trans_queue_pop",
#       "stat_slow_trans_queue_push",
#       "stat_write_errs",
#       "stat_write_errs_notfound",
#       "stat_write_errs_other",
#       "stat_write_reqs",
#       "stat_write_reqs_xdr",
#       "stat_write_success",
#       "stat_xdr_pipe_miss",
#       "stat_xdr_pipe_writes",
#       "stat_zero_bin_records",
#       "storage_defrag_corrupt_record",
#       "transactions",
#       "tscan_aborted",
#       "tscan_initiate",
#       "tscan_pending",
#       "tscan_succeeded",
#       "udf_bg_scans_succeeded",
#       "udf_bg_scans_failed",
#       "udf_delete_err_others",
#       "udf_delete_reqs",
#       "udf_delete_success",
#       "udf_lua_errs",
#       "udf_query_rec_reqs",
#       "udf_read_errs_other",
#       "udf_read_reqs",
#       "udf_read_success",
#       "udf_replica_writes",
#       "udf_scan_rec_reqs",
#       "udf_write_err_others",
#       "udf_write_reqs",
#       "udf_write_success",
#       "write_master",
#       "write_prole",
#       "xdr_deletes_canceled",
#       "xdr_deletes_shipped",
#       "xdr_hotkey_fetch",
#       "xdr_hotkey_skip",
#       "xdr_queue_overflow_error",
#       "xdr_read_error",
#       "xdr_read_not_found",
#       "xdr_read_reqq_used",
#       "xdr_read_respq_used",
#       "xdr_read_success",
#       "xdr_relogged_incoming",
#       "xdr_relogged_outgoing",
#       "xdr_ship_bytes",
#       "xdr_ship_delete_success",
#       "xdr_ship_destination_error",
#       "xdr_ship_inflight_objects",
#       "xdr_ship_fullrecord",
#       "xdr_ship_outstanding_objects",
#       "xdr_ship_source_error",
#       "xdr_ship_success",
#       "xdr_uninitialized_destination_error",
#       "xdr_unknown_namespace_error",
#       "xdr_uptime",
#       "batch_sub_proxy_complete",
#       "batch_sub_proxy_error",
#       "batch_sub_proxy_timeout",
#       "batch_sub_read_error",
#       "batch_sub_read_not_found",
#       "batch_sub_read_success",
#       "batch_sub_read_timeout",
#       "batch_sub_tsvc_error",
#       "batch_sub_tsvc_timeout",
#       "client_delete_error",
#       "client_delete_not_found",
#       "client_delete_success",
#       "client_delete_timeout",
#       "client_lang_delete_success",
#       "client_lang_error",
#       "client_lang_read_success",
#       "client_lang_write_success",
#       "client_proxy_complete",
#       "client_proxy_error",
#       "client_proxy_timeout",
#       "client_read_error",
#       "client_read_not_found",
#       "client_read_success",
#       "client_read_timeout",
#       "client_tsvc_error",
#       "client_tsvc_timeout",
#       "client_udf_complete",
#       "client_udf_error",
#       "client_udf_timeout",
#       "client_write_error",
#       "client_write_success",
#       "client_write_timeout",
#       "demarshal_error",
#       "evicted-objects",
#       "evicted_objects",
#       "evict_ttl",
#       "expired-objects",
#       "expired_objects",
#       "fail_generation",
#       "fail_key_busy",
#       "fail_record_too_big",
#       "fail_xdr_forbidden",
#       "geo_region_query_cells",
#       "geo_region_query_falsepos",
#       "geo_region_query_points",
#       "geo_region_query_reqs",
#       "ldt_deletes",
#       "ldt_delete_success",
#       "ldt_errors",
#       "ldt_reads",
#       "ldt_read_success",
#       "ldt_updates",
#       "ldt_writes",
#       "ldt_write_success",
#       "migrate-record-receives",
#       "migrate_record_receives",
#       "migrate-record-retransmits",
#       "migrate_record_retransmits",
#       "migrate-records-skipped",
#       "migrate_records_skipped",
#       "migrate-records-transmitted",
#       "migrate_records_transmitted",
#       "query_abort",
#       "query_agg",
#       "query_agg_abort",
#       "query_agg_avg_rec_count",
#       "query_agg_error",
#       "query_agg_success",
#       "query_avg_rec_count",
#       "query_fail",
#       "query_long_queue_full",
#       "query_long_reqs",
#       "query_lookup_abort",
#       "query_lookup_avg_rec_count",
#       "query_lookup_err",
#       "query_lookup_success",
#       "query_lookups",
#       "query_reqs",
#       "query_short_queue_full",
#       "query_short_reqs",
#       "query_success",
#       "query_udf_bg_failure",
#       "query_udf_bg_success",
#       "scan_aggr_abort",
#       "scan_aggr_complete",
#       "scan_aggr_error",
#       "scan_basic_abort",
#       "scan_basic_complete",
#       "scan_basic_error",
#       "scan_udf_bg_abort",
#       "scan_udf_bg_complete",
#       "scan_udf_bg_error",
#       "set-deleted-objects",
#       "set_deleted_objects",
#       "set-evicted-objects",
#       "udf_sub_lang_delete_success",
#       "udf_sub_lang_error",
#       "udf_sub_lang_read_success",
#       "udf_sub_lang_write_success",
#       "udf_sub_udf_complete",
#       "udf_sub_udf_error",
#       "udf_sub_udf_timeout",
#       "udf_sub_tsvc_error",
#       "udf_sub_tsvc_timeout",
#       "xdr_read_success",
#       "xdr_write_error",
#       "xdr_write_success",
#       "xdr_write_timeout",
#       "dc_remote_ship_ok",
#       "dc_rec_ship_attempts",
#       "dc_delete_ship_attempts",
#       "dc_ship_attempt",
#       "dc_ship_delete_success",
#       "dc_ship_destination_error",
#       "dc_ship_source_error",
#       "dc_ship_success",
#     ],
#     # service - required: false  - string
#     "service" => nil,
#   },
# }

datadog_monitor 'aerospike' do
  init_config node['datadog']['aerospike']['init_config']
  instances node['datadog']['aerospike']['instances']
  logs node['datadog']['aerospike']['logs']
  use_integration_template true
  action :add
  notifies :restart, 'service[datadog-agent]' if node['datadog']['agent_start']
end
