#
# Cookbook:: test
# Recipe:: create
#
# Copyright:: 2013-2019, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distribued on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

apt_update 'update'

include_recipe 'lvm'

# The test device to use
devices = [
  '/dev/loop0',
  '/dev/loop1',
  '/dev/loop2',
  '/dev/loop3',
  '/dev/loop4',
  '/dev/loop5',
  '/dev/loop6',
  '/dev/loop7',
]

loop_devices 'loop_devices' do
  devices devices
  action :create
end

# Creates the physical device

log 'Creating physical volume for test'
devices.each do |device|
  lvm_physical_volume device
end

# Verify that the create action is idempotent
lvm_physical_volume devices.first

# Creates the volume group
#
lvm_volume_group 'vg-data' do
  physical_volumes ['/dev/loop0', '/dev/loop1', '/dev/loop2', '/dev/loop3']

  logical_volume 'logs' do
    size '10M'
    filesystem 'ext2'
    mount_point location: '/mnt/logs', options: 'noatime,nodiratime'
    stripes 2
  end

  logical_volume 'home' do
    size '5M'
    filesystem 'ext2'
    mount_point '/mnt/home'
    stripes 1
    mirrors 2
  end
end

lvm_volume_group 'vg-test' do
  physical_volumes ['/dev/loop4', '/dev/loop5', '/dev/loop6']
end

lvm_volume_group 'vg-test-extend' do
  action :extend
  name 'vg-test'
  physical_volumes ['/dev/loop4', '/dev/loop5', '/dev/loop6', '/dev/loop7']
end
# Creates the logical volume
#
lvm_logical_volume 'test' do
  group 'vg-test'
  size '50%VG'
  filesystem 'ext3'
  mount_point '/mnt/test'
  ignore_skipped_cluster true
end

# Creates a small logical volume
#
lvm_logical_volume 'small' do
  group 'vg-test'
  size '2%VG'
  filesystem 'ext3'
  mount_point '/mnt/small'
end

# Set the directory attributes of the mounted volume
#
directory '/mnt/small' do
  mode '0555'
  owner 1
  group 1
  only_if { File.stat('/mnt/small') != 0100555 }
end

# Creates a small logical volume
#
lvm_logical_volume 'small' do
  group 'vg-test'
  size '2%VG'
  filesystem 'ext3'
  mount_point '/mnt/small'
end
