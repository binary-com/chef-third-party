# Poise-Build-Essential Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-build-essential.svg)](https://travis-ci.org/poise/poise-build-essential)
[![Gem Version](https://img.shields.io/gem/v/poise-build-essential.svg)](https://rubygems.org/gems/poise-build-essential)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-build-essential.svg)](https://supermarket.chef.io/cookbooks/poise-build-essential)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-build-essential.svg)](https://codecov.io/github/poise/poise-build-essential)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-build-essential.svg)](https://gemnasium.com/poise/poise-build-essential)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to install a C compiler and build tools..

## Quick Start

To install a C compiler:

```ruby
include_recipe 'poise-build-essential'
```

Or to install using a resource and at compile time:

```ruby
poise_build_essential 'build_essential' do
  action :nothing
end.run_action(:install)
```

## Recipes

* `poise-build-essential::default` – Install a C compiler and build tools.

## Attributes

* `node['poise-build-essential']['action']` – Action to use. One of install,
  upgrade, or remove. *(default: install)*
* `node['poise-build-essential']['allow_unsupported_platform']` – Whether or not
  to raise an error on unsupported platforms. *(default: false)*

## Resources

### `poise_build_essential`

The `poise_build_essential` resource installs a C compiler and build tools.

```ruby
poise_build_essential 'build_essential' do
  allow_unsupported_platform true
end
```

#### Actions

* `:install` – Install a C compiler. *(default)*
* `:upgrade` – Install a C compiler using `package action :ugprade` rules.
* `:remove` – Remove a C compiler.

#### Properties

* `allow_unsupported_platform` – Whether or not to raise an error on unsupported
  platforms. *(default: false)*

## Sponsors

Development sponsored by [SAP](https://www.sap.com/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Some code copyright 2008-2017, Chef Software, Inc. Used under the terms of the
Apache License, Version 2.0.

Copyright 2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
