require 'spec_helper'

describe 'docker_test::exec' do
  cached(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '18.04').converge(described_recipe) }

  it 'pull_if_missing docker_image[busybox]' do
    expect(chef_run).to pull_if_missing_docker_image('busybox')
  end

  it 'run docker_container[busybox_exec]' do
    expect(chef_run).to run_docker_container('busybox_exec').with(
      repo: 'busybox',
      command: ['sh', '-c', 'trap exit 0 SIGTERM; while :; do sleep 1; done']
    )
  end

  # TODO(ramereth): Disabling due to https://github.com/sous-chefs/docker/issues/1137
  # context 'testing default properties' do
  #   it 'docker_exec[default]' do
  #     expect(chef_run).to run_docker_exec('default').with(
  #       host: nil,
  #       command: nil,
  #       container: nil,
  #       timeout: 60,
  #       container_obj: nil,
  #       returns: [0]
  #     )
  #   end
  # end

  context 'testing run action' do
    it 'run docker_exec[touch_it]' do
      expect(chef_run).to run_docker_exec('touch_it').with(
        container: 'busybox_exec',
        command: ['touch', '/tmp/onefile'],
        timeout: 120
      )
    end

    it 'creates file[/marker_busybox_exec_onefile]' do
      expect(chef_run).to create_file('/marker_busybox_exec_onefile')
    end

    it 'run docker_exec[another]' do
      expect(chef_run).to run_docker_exec('poke_it').with(
        container: 'busybox_exec',
        command: ['touch', '/tmp/twofile']
      )
    end

    it 'creates file[/marker_busybox_exec_twofile]' do
      expect(chef_run).to create_file('/marker_busybox_exec_twofile')
    end
  end
end
