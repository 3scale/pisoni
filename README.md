[![Code Climate](https://codeclimate.com/repos/5332be496956802e3c007d1a/badges/b4f1c55f9ff033c5f0d8/gpa.svg)](https://codeclimate.com/repos/5332be496956802e3c007d1a/feed)
[![Test Coverage](https://codeclimate.com/repos/5332be496956802e3c007d1a/badges/b4f1c55f9ff033c5f0d8/coverage.svg)](https://codeclimate.com/repos/5332be496956802e3c007d1a/feed)

# 3scale API Management System Core Libraries

Core libraries for 3scale systems.

## Install

    $ rvm use ruby-2.1.1

    $ gem build 3scale_core.gemspec

    $ gem install 3scale_core-x.y.z.gem

where x.y.z is the version you aim for

## Development

### Environment set up

You will want to run tests in an isolated environment. We rely on Vagrant to
manage such an environment, and on Docker to provide it (in the past we also
used VirtualBox, but we no longer support it).

The way to get you started is to visit the root of the project and type:

    $ vagrant up

This will probably fail if you haven't set up your `${HOME}/.dockercfg` file
with quay.io credentials. Ask someone to set up your account there and then
download your credentials and retry.

Once that command finishes, you can enter the testing environment with:

    $ vagrant ssh

From now on, all commands should be entered within the environment you just entered.

### Running tests

You can run both tests & specs with:

    $ bundle install
    $ bundle exec rake

If you want to generate new ones (or responses changed), you need to have a
working instance of backend server with a freshly cleared database and you can
run it like this:

    $ bundle exec rake ci

You will need to start backend's database beforehand. If you don't want to take
care of those details, just use the `script/ci` script to have everything set up
for you (including cleaning up).

Note that this relies on a local backend gem, which may or may not be what you
need for testing. Use the environment variable `THREESCALE_CORE_INTERNAL_API` to
point the tests to your running backend instance:

    $ THREESCALE_CORE_INTERNAL_API=http://172.17.42.1:8081/internal bundle exec rake ci

> Note: the external IP address depends on the provider. Docker uses `172.17.42.1` while VirtualBox uses `10.0.2.2`.

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
