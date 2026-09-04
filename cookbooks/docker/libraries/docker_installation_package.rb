module DockerCookbook
  class DockerInstallationPackage < DockerBase
    resource_name :docker_installation_package
    provides :docker_installation_package

    property :setup_docker_repo, [true, false], default: true, desired_state: false
    property :repo_channel, String, default: 'stable'
    property :package_name, String, default: 'docker-ce', desired_state: false
    property :package_version, String, desired_state: false
    property :version, String, desired_state: false
    property :package_options, String, desired_state: false

    def el7?
      return true if platform_family?('rhel') && node['platform_version'].to_i == 7
      false
    end

    def fedora?
      return true if platform?('fedora')
      false
    end

    def debuntu?
      return true if platform_family?('debian')
      false
    end

    def debian?
      return true if platform?('debian')
      false
    end

    def ubuntu?
      return true if platform?('ubuntu')
      false
    end

    def stretch?
      return true if platform?('debian') && node['platform_version'].to_i == 9
      false
    end

    def buster?
      return true if platform?('debian') && node['platform_version'].to_i == 10
      false
    end

    def bullseye?
      return true if platform?('debian') && node['platform_version'].to_i == 11
      false
    end

    def trixie?
      return true if platform?('debian') && node['platform_version'].to_i == 13
      false
    end

    def bionic?
      return true if platform?('ubuntu') && node['platform_version'] == '18.04'
      false
    end

    def focal?
      return true if platform?('ubuntu') && node['platform_version'] == '20.04'
      false
    end

    # https://github.com/chef/chef/issues/4103
    def version_string(v)
      return if v.nil?

      # If the caller already provides a fully-qualified Docker package version
      # (e.g. "5:28.5.2-1~debian.13~trixie"), use it verbatim. The heuristics
      # below only know how to build the legacy "~ce~3-0~debian-<codename>"
      # style strings, which no longer match the packages published for newer
      # Debian releases such as trixie.
      return v if v =~ /~debian\.\d+~|~ubuntu\.\d+~|~ce/ || v.include?(':')

      codename = if stretch? # deb 9
                   'stretch'
                 elsif buster? # deb 10
                   'buster'
                 elsif bullseye? # deb 11
                   'bullseye'
                 elsif trixie? # deb 13
                   'trixie'
                 elsif bionic? # ubuntu 18.04
                   'bionic'
                 elsif focal? # ubuntu 20.04
                   'focal'
                 end

      # https://github.com/seemethere/docker-ce-packaging/blob/9ba8e36e8588ea75209d813558c8065844c953a0/deb/gen-deb-ver#L16-L20
      test_version = '3'

      if v.to_f < 18.06 && !bionic?
        return "#{v}~ce-0~debian" if debian?
        return "#{v}~ce-0~ubuntu" if ubuntu?
      elsif v.to_f >= 18.09 && debuntu?
        return "5:#{v}~#{test_version}-0~debian-#{codename}" if debian?
        return "5:#{v}~#{test_version}-0~ubuntu-#{codename}" if ubuntu?
      else
        return "#{v}~ce~#{test_version}-0~debian" if debian?
        return "#{v}~ce~#{test_version}-0~ubuntu" if ubuntu?
        v
      end
    end

    action :create do
      if new_resource.setup_docker_repo
        if platform_family?('rhel', 'fedora')
          arch = node['kernel']['machine']
          platform =
            if platform?('fedora')
              'fedora'
            # s390x is only available under rhel platform
            elsif platform?('redhat') && arch == 's390x'
              'rhel'
            else
              'centos'
            end

          yum_repository 'Docker' do
            baseurl "https://download.docker.com/linux/#{platform}/#{node['platform_version'].to_i}/#{arch}/#{new_resource.repo_channel}"
            gpgkey "https://download.docker.com/linux/#{platform}/gpg"
            description "Docker #{new_resource.repo_channel.capitalize} repository"
            gpgcheck true
            enabled true
          end
        elsif platform_family?('debian')
          deb_arch =
            case node['kernel']['machine']
            when 'x86_64'
              'amd64'
            when 'aarch64'
              'arm64'
            when 'armv7l'
              'armhf'
            when 'ppc64le'
              'ppc64el'
            else
              node['kernel']['machine']
            end

          package 'apt-transport-https'

          # Debian 13 (trixie) and modern apt no longer ship `apt-key`.
          # Install the Docker GPG key into a dedicated keyring and reference
          # it via the `signed-by` option instead of the deprecated apt-key flow.
          directory '/etc/apt/keyrings' do
            mode '0755'
            recursive true
          end

          docker_apt_keyring = '/etc/apt/keyrings/docker.asc'

          remote_file docker_apt_keyring do
            source "https://download.docker.com/linux/#{node['platform']}/gpg"
            mode '0644'
          end

          apt_repository 'Docker' do
            components Array(new_resource.repo_channel)
            uri "https://download.docker.com/linux/#{node['platform']}"
            arch deb_arch
            options "signed-by=#{docker_apt_keyring}"
            action :add
          end
        else
          Chef::Log.warn("Cannot setup the Docker repo for platform #{node['platform']}. Skipping.")
        end
      end

      version = new_resource.package_version || version_string(new_resource.version)

      # On Debian/Ubuntu, explicitly install the CLI (and containerd) in addition
      # to the docker-ce (daemon) package. Relying solely on docker-ce's
      # dependency resolution can leave /usr/bin/docker (docker-ce-cli) missing
      # when apt pin priorities force specific versions, which produces a golden
      # image whose `docker` command is absent even though the daemon converged.
      if debuntu?
        package 'docker-ce-cli' do
          version version
          options new_resource.package_options
          retries 6
          retry_delay 15
          action :install
        end
      end

      package new_resource.package_name do
        version version
        options new_resource.package_options
        retries 6
        retry_delay 15
        action :install
      end
    end

    action :delete do
      package new_resource.package_name do
        action :remove
      end
    end
  end
end
