[![Code Climate](https://codeclimate.com/repos/5332be496956802e3c007d1a/badges/b4f1c55f9ff033c5f0d8/gpa.svg)](https://codeclimate.com/repos/5332be496956802e3c007d1a/feed)
[![Test Coverage](https://codeclimate.com/repos/5332be496956802e3c007d1a/badges/b4f1c55f9ff033c5f0d8/coverage.svg)](https://codeclimate.com/repos/5332be496956802e3c007d1a/feed)

# 3scale API Management System Core Libraries

Core libraries for 3scale systems.

## Install

    $ rvm use ruby-2.1.2

    $ gem build 3scale_core.gemspec

    $ gem install 3scale_core-x.y.z.gem

where x.y.z is the version you aim for

## Development

### Environment set up

We are using [Docker Compose](https://docs.docker.com/compose/) to run the tests in an isolated
environment. First, you need to make sure that the core and backend projects are under the same 
directory. Then, from the root of the core project, run:
    
    $ make bash
    
This will create two containers: one with core and all its dependencies, and another one
with backend (using the code that you have under `../backend`). This way, we can test core against
the backend container. When the command above finishes, you'll get a shell in the core container. 

If the command above fails, make sure to include your quay.io credentials in your 
`${HOME}/.dockercfg` file with quay.io credentials.

### Running tests

You can run both tests & specs with:

    $ bundle install
    $ bundle exec rake

You can also test core against a different backend instance. Use the environment variable 
`THREESCALE_CORE_INTERNAL_API` to point the tests to your running backend instance:

    $ THREESCALE_CORE_INTERNAL_API=http://172.17.42.1:8081/internal bundle exec rake
                                                             
> Note: the external IP address depends on the provider. Docker uses `172.17.42.1` 
while VirtualBox uses `10.0.2.2`.

You can also test core against the latest backend image available in quay.io, instead of testing
against the code under `../backend`. Instead of creating the containers like described above,
you just need to run:

    $ make test

#### Setting up the environment for testing

During normal development in both backend and core, you would want to either use
the latest backend as a virtual machine on its own and then pointing the internal
API URL environment variable `THREESCALE_CORE_INTERNAL_API` to it for testing as
described above, or make sure Core's `Gemfile` points to whatever version from
backend you want and installing that to the bundler's gem cache, ie. copying it
to `<core>/vendor/cache/3scale_backend-2.26.0.gem`.

This way you don't need to set environment variables nor launch additional VMs,
but it is more error-prone than just using the facilities in backend to let it
listen for requests on its own VM and using the environment variable here.

#### Update the version of this gem

Modify the version number in lib/3scale/core/version.rb. For this instructions we are going to assume version 1.12.1

Specify the version number in the commit message

    $ git commit -m "core: release 1.12.1"

Create a tag with the version number and a message. The first line of the message should be the version number

    $ git tag -a v1.12.1 -m "v1.12.1"

Push directly to master

    $ git push origin master v1.12.1

Build the gem

    $ bundle exec rake build

Apart from 'build', there are other tasks available. You can list them with:

    $ bundle exec rake -T

Push the new version of the gem to our repo

    $ bundle exec gem inabox pkg/3scale_core-1.12.1.gem

Introduce the host with the appropriate user and password like this: https://user:pass@host
