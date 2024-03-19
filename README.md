[![CircleCI](https://circleci.com/gh/3scale/pisoni.svg?style=shield)](https://circleci.com/gh/3scale/pisoni)
[![Maintainability](https://api.codeclimate.com/v1/badges/4b18ae93abefdba17e0b/maintainability)](https://codeclimate.com/github/3scale/pisoni/maintainability)
[![Gem Version](https://badge.fury.io/rb/pisoni.svg)](https://badge.fury.io/rb/pisoni)

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

### Running tests with `make` and `podman-compose`

We are using [podman-compose](https://github.com/containers/podman-compose) to run the dependencies (redis and apisonator) for the tests.
You need to have it installed locally.

You can run the test suite (with the required dependencies) by executing `make test`.

For cleaning up the dependencies containers, you can run `make deps_down`.

### Running tests locally

You can run both tests & specs with:

> $ bundle exec rake

You can also test against a different Apisonator instance. Use the environment
variable  `THREESCALE_CORE_INTERNAL_API` to point the tests to your running
backend instance:

> $ THREESCALE_CORE_INTERNAL_API=http://user:passwd@172.17.42.1:8081/internal bundle exec rake
