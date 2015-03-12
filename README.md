# 3scale API Management System Core Libraries

Core libraries for 3scale systems.

## Install

    $ rvm use ruby-2.1.1

    $ gem build 3scale_core.gemspec

    $ gem install 3scale_core-x.y.z.gem

where x.y.z is the version you aim for

## Development

### Running tests

You can run both tests & specs using API responses cached with VCR:

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

#### VCR and modified cassettes

Note that sometimes, when you run a full CI test, the cassettes will contain some
differences even if nothing changed in the tests or the API. This is due to VCR
adding what it thinks are different responses to the same requests. If you take a
closer look, you'll see VCR just switched order between existing pairs of requests
and responses.

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
