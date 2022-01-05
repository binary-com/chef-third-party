apache2_install 'default' do
  mpm 'prefork'
end

service 'apache2' do
  service_name lazy { apache_platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end

apache2_mod_auth_cas 'default' do
  directives(
    'CASCookiePath' => "#{cache_dir}/mod_auth_cas/"
  )
end
