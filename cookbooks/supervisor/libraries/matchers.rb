if defined?(ChefSpec)
  def enable_supervisor_service(service_name)
    ChefSpec::Matchers::ResourceMatcher.new(:supervisor_service, :enable, service_name)
  end

  def disable_supervisor_service(service_name)
    ChefSpec::Matchers::ResourceMatcher.new(:supervisor_service, :disable, service_name)
  end

  def start_supervisor_service(service_name)
    ChefSpec::Matchers::ResourceMatcher.new(:supervisor_service, :start, service_name)
  end

  def stop_supervisor_service(service_name)
    ChefSpec::Matchers::ResourceMatcher.new(:supervisor_service, :stop, service_name)
  end

  def restart_supervisor_service(service_name)
    ChefSpec::Matchers::ResourceMatcher.new(:supervisor_service, :restart, service_name)
  end

end
