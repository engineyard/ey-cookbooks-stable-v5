# engineyard-docker

Chef repository and  wrapper cookbook to deploy Docker on a utility instance in
Engineyard's 2016 stack.

## Docker Hub Credentials

If you need to input your Docker Hub credentials (or any other registry) to pull 
Docker images, perform the following steps:


1.  Login to your Docker host. By default it will be the util instance named
    `docker`.
2.  Run `docker login` and input your credentials.
3.  Check that you have generated your credentials file in
    `~deploy/.docker/config.json`.

## Third-party Docker Registries

To add additional registries, perform the following steps:

1. Update the `node['docker_custom']['registries']` attribute with the address
   of the Docker registry you are adding.
2. Run `docker login <address-of-other-registry>` to insert credentials for your
   third-party Docker registry.

## Alternative approaches

You can upload your `~/.docker/config.json` file from your workstation to your
instances instead.

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

