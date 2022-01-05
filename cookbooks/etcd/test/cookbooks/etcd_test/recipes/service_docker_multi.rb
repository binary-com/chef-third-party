# binary installation for kitchen verify
etcd_installation_binary 'default' do
  action :create
end

# docker_service for the containers to run in
docker_service 'default' do
  storage_driver 'vfs'
end

# Make sure we have the image
etcd_installation_docker 'default'

# https://coreos.com/etcd/docs/2.2.2/clustering.html
# https://coreos.com/etcd/docs/2.2.2/docker_guide.html
# Static Clustering

etcd_service_manager_docker 'etcd0' do
  advertise_client_urls 'http://127.0.0.1:2379'
  listen_client_urls 'http://0.0.0.0:2379'
  initial_advertise_peer_urls 'http://127.0.0.1:2380'
  listen_peer_urls 'http://0.0.0.0:2380'
  initial_cluster_token 'etcd-cluster-1'
  initial_cluster 'etcd0=http://127.0.0.1:2380,etcd1=http://127.0.0.1:3380,etcd2=http://127.0.0.1:4380'
  initial_cluster_state 'new'
  port ['2380:2380', '2379:2379']
  action :start
end

etcd_service_manager_docker 'etcd1' do
  advertise_client_urls 'http://127.0.0.1:3379'
  listen_client_urls 'http://0.0.0.0:3379'
  initial_advertise_peer_urls 'http://127.0.0.1:3380'
  listen_peer_urls 'http://0.0.0.0:3380'
  initial_cluster_token 'etcd-cluster-1'
  initial_cluster 'etcd0=http://127.0.0.1:2380,etcd1=http://127.0.0.1:3380,etcd2=http://127.0.0.1:4380'
  initial_cluster_state 'new'
  port ['3379:3379', '3380:3380']
  action :start
end

etcd_service_manager_docker 'etcd2' do
  advertise_client_urls 'http://127.0.0.1:4379'
  listen_client_urls 'http://0.0.0.0:4379'
  initial_advertise_peer_urls 'http://127.0.0.1:4380'
  listen_peer_urls 'http://0.0.0.0:4380'
  initial_cluster_token 'etcd-cluster-1'
  initial_cluster 'etcd0=http://127.0.0.1:2380,etcd1=http://127.0.0.1:3380,etcd2=http://127.0.0.1:4380'
  initial_cluster_state 'new'
  port ['4379:4379', '4380:4380']
  action :start
end
