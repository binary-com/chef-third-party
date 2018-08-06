# Poise-Git Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-git.svg)](https://travis-ci.org/poise/poise-git)
[![Gem Version](https://img.shields.io/gem/v/poise-git.svg)](https://rubygems.org/gems/poise-git)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-git.svg)](https://supermarket.chef.io/cookbooks/poise-git)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-git.svg)](https://codecov.io/github/poise/poise-git)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-git.svg)](https://gemnasium.com/poise/poise-git)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to manage [Git](https://git-scm.com/).

## Quick Start

To install Git and clone a repository using a deploy key from a data bag:

```ruby
poise_git '/srv/myapp' do
  repository 'git@github.com:example/myapp.git'
  deploy_key data_bag_item('keys', 'myapp')['key']
end
```

To install Git and clone a repository using a deploy key that already exists on
disk:

```ruby
poise_git '/srv/myapp' do
  repository 'git@github.com:example/myapp.git'
  deploy_key '/path/to/mykey.pem'
end
```

## Recipes

* `poise-git::default` – Install Git.

## Attributes

* `node['poise-git']['default_recipe']` – Recipe used by `poise_git` to install
  Git if not already available. *(default: poise-git)*
* `node['poise-git']['provider']` – Default provider for `poise_git_client` resource
  instances. *(default: auto)*
* `node['poise-git']['recipe'][*]` – All subkeys of `'recipe'` will be passed
  as properties to the `poise_git_client` resource before installation when using
  the `poise-git::default` recipe.

## Resources

### `poise_git`

The `poise_git` resource extends the core `git` resource, adding a `deploy_key`
property to use SSH deploy keys automatically.

```ruby
poise_git '/srv/myapp' do
  repository 'git@github.com:example/myapp.git'
  deploy_key 'mysecretkey'
end
```

The `poise_git` resource supports all the same actions and properties as the
core `git` resource.

The `deploy_key` property can either be passed the absolute path to an existing
SSH key file, or the raw SSH private key text.

### `poise_git_client`

The `poise_git_client` resource installs Git.

```ruby
poise_git_client 'git'
```

#### Actions

* `:install` – Install Git. *(default)*
* `:uninstall` – Uninstall Git.

#### Properties

* `version` – Version of Git to install. If a partial version is given, use the
  latest available version matching that prefix. *(name property)*

#### Provider Options

The `poise_git_client` resource uses provide options for per-provider configuration. See
[the poise-service documentation](https://github.com/poise/poise-service#service-options)
for more information on using provider options.

## Git Client Providers

### `system`

The `system` provider installs Git using system packages. This is currently
only tested on platforms using `apt-get` and `yum` (Debian, Ubuntu, RHEL, CentOS
Amazon Linux, and Fedora) and is a default provider on those platforms. It may
work on other platforms but is untested.

```ruby
poise_git_client 'git' do
  provider :system
end
```

#### Options

* `package_name` – Override auto-detection of the package name.
* `package_upgrade` – Install using action `:upgrade`. *(default: false)*
* `package_version` – Override auto-detection of the package version.

### `dummy`

The `dummy` provider supports using the `poise_git_client` resource with ChefSpec
or other testing frameworks to not actually install Git. It is used by default under
ChefSpec. It can also be used to manage the Git installation externally from
this cookbook.

```ruby
poise_git_client 'git' do
  provider :dummy
  options git_binary: '/path/to/git'
end
```

#### Provider Options

* `git_binary` – Path to the `git` executable. *(default: /git)*
* `git_environment` – Hash of environment variables to use with this Git. *(default: {})*

## Sponsors

Development sponsored by [SAP](https://www.sap.com/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2015-2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
