# Change Log

Notable changes to Pisoni will be tracked in this document.

## 1.29.1 - 2023-11-30

### Changed

- Fixed the issue with updating/deleting keys for applications with special characters in the
application IDs by escaping them. [#31](https://github.com/3scale/pisoni/pull/31)

## 1.29.0 - 2020-03-17

### Removed

- "Latest transactions" functionality
[#27](https://github.com/3scale/pisoni/pull/27)

## 1.28.0 - 2019-12-20

### Changed

- `Service.delete_stats` has been adapted to the changes in Apisonator. Now it
only needs to receive the service ID as a param and deletes all the stats for
that service. The second param of the function, "delete_job" is ignored now.
[#24](https://github.com/3scale/pisoni/pull/24)

### Removed

- Support for end-users, a feature that's no longer supported in recent
Apisonator. [#25](https://github.com/3scale/pisoni/pull/25)

## 1.27.0 - 2019-06-28

### Added

- Support for app credentials with special characters ('*', '$', etc.). [#22](https://github.com/3scale/pisoni/pull/22)

## 1.26.0 - 2019-03-05

### Added

- The stats of a service can now be deleted. [#19](https://github.com/3scale/pisoni/pull/19)

### Changed

- Ruby 2.2 is no longer supported. The minimum version is 2.3.0. [#18](https://github.com/3scale/pisoni/pull/18)

## 1.25.0 - 2019-02-20

### Added

- Applications can now be activated/deactivated. [#12](https://github.com/3scale/pisoni/pull/12)
- Users of a service can now be deleted. [#15](https://github.com/3scale/pisoni/pull/15)

## 1.24.0 - 2018-06-29

### Added

- Services can now be activated/deactivated based on the `state` attribute.
  ([#7](https://github.com/3scale/pisoni/pull/7))

## 1.23.2 - 2018-06-04

### Changed

- Use `[pisoni]` as default logline prefix instead of `[core]`. ([#5](https://github.com/3scale/pisoni/pull/5))
- Relax requirement on Faraday version and warn when the user might find issues
  with old versions. ([#4](https://github.com/3scale/pisoni/pull/4))

## 1.23.1 - 2018-05-29

### Added

- Initial version published under the Apache 2.0 license.
