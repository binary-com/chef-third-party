#
# Copyright 2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Default recipe to use to install git.
default['poise-git']['default_recipe'] = 'poise-git'

# Default inversion options.
default['poise-git']['provider'] = 'auto'
default['poise-git']['options'] = {}

# Attributes for recipe[poise-git]. All values are nil because the actual
# defaults live in the resource.
default['poise-git']['recipe']['version'] = nil
