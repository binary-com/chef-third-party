if os.redhat?
  include_dir = '/etc/my.cnf.d'
  libgalera_smm_path = '/usr/lib64/galera/libgalera_smm.so'
else
  include_dir = '/etc/mysql/conf.d'
  libgalera_smm_path = '/usr/lib/galera/libgalera_smm.so'
end

galera_config_file = "#{include_dir}/90-galera.cnf"
ip_address = sys_info.ip_address.strip

control 'mariadb_galera_configuration' do
  impact 1.0
  title 'test global installation when galera configuration'

  describe service('mysql') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port('3306') do
    it { should be_listening }
  end
end

control 'mariadb_galera_configuration' do
  impact 1.0
  title "verify the rendered config in #{galera_config_file}"

  content = <<-EOF.gsub(/^\s+/, '')
    # DEPLOYED BY CHEF
    [mysqld]
    query_cache_size = 0
    binlog_format = ROW
    default_storage_engine = InnoDB
    innodb_autoinc_lock_mode = 2
    innodb_doublewrite = 1
    server_id = 100
    innodb_flush_log_at_trx_commit = 2
    wsrep_on = ON
    wsrep_provider_options = "gcache.size=512M"
    wsrep_cluster_address = gcomm://
    wsrep_cluster_name = galera_cluster
    wsrep_sst_method = mariabackup
    wsrep_sst_auth = sstuser:some_secret_password
    wsrep_provider = #{libgalera_smm_path}
    wsrep_slave_threads = 8
    wsrep_node_address = #{ip_address}
  EOF

  describe file(galera_config_file) do
    its('content') { should eq content }
  end

  describe mysql_session('root', 'gsql').query('show status like "wsrep_%";') do
    {
      'wsrep_cluster_size' => '1',
      'wsrep_cluster_status' => 'Primary',
      'wsrep_evs_state' => 'OPERATIONAL',
      'wsrep_ready' => 'ON',
    }.each_pair do |k, v|
      its('output') { should match(/^#{k}\s*#{v}$/) }
    end
  end
end
