# engineyard_docker

Chef wrapper library cookbook to deploy Docker on a utility instance in
Engineyard's 2016 stack.

This cookbook wraps the community Docker cookbook.

## Cookbook Dependencies

- [docker](https://supermarket.chef.io/cookbooks/docker)

## Instructions

The sample `Berksfile` generates the main Cookbook that the Engineyard CLI
recognizes:

```
berks vendor output/cookbooks
cd output
ey upload -e <target_environment>
ey apply -e <target_environment>
```

The sample main cookbook can be found in `test/cookbooks/main`.

## Resources overview

- `docker_installation_package_ebuild`: provides `docker_installation_package`
  for Gentoo platforms.
- `docker_service_manager_openrc`: manage docker daemon with an openrc script.

## docker_installation_package_ebuild

The `docker_installation_package_ebuild` resource uses the Gentoo's emerge
system package manager to install Docker. It relies on the pre-configuration of
the system's package repositories. 

This is the recommended production installation method.

### Example

```ruby
docker_installation_package 'default' do
  version '1.8.3'
  action :create
end
```

### Properties

- `version` - Used to calculate package_version string
- `package_version` - Manually specify the package version string
- `package_name` - Name of package to install. Defaults to 'docker-engine'
- `package_options` - Manually specify additional options, like emerge directives for example

## docker_service_manager_openrc

### Example

```ruby
docker_service_manager_openrc 'default' do
  action :start
end
```

See the upstream cookbook for its properties
<https://github.com/chef-cookbooks/docker#properties-3>.

## LICENSE

Copyright © 2016 Engine Yard, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

