# Pisoni

Pisoni is a Ruby client for the internal API of the
[Apisonator](https://github.com/3scale/apisonator) component of the 3scale API
Management software. This API allows third parties to push model data to the
Apisonator data store.

## License

This Ruby gem is licensed under the Apache 2.0 license.

## Install

You can add this gem to your Gemfile, or install it in your system with:

> $ gem install pisoni -v '= x.y.z'

where x.y.z is the version you aim for.

## Development

### Environment set up

We are using [Docker Compose](https://docs.docker.com/compose/) to run the tests
in an isolated environment.

You should first `make pull build` to download the needed images and build the
one used for actual testing and development.

You can then run `make test` to run the test suite, and `make dev` to enter
a container in which the code is sync'ed back to your host.

For cleaning up containers, volumes and networks you can run `make clean` and
`make destroy`. If you want to also get rid of pulled images, run `make
destroy-all`.

### Running tests

You can run both tests & specs with:

> $ bundle exec rake

You can also test against a different Apisonator instance. Use the environment
variable  `THREESCALE_CORE_INTERNAL_API` to point the tests to your running
backend instance:

> $ THREESCALE_CORE_INTERNAL_API=http://user:passwd@172.17.42.1:8081/internal bundle exec rake
