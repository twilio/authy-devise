# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

...

## [1.11.1] - 2019-02-02

### Fixed

- Using the version before loading it broke everything. :facepalm:

## [1.11.0] - 2019-02-01

### Fixed

- Corrects for label in verify_authy view (#103 thanks @mstruebing)
- Corrects heading in verify_authy view (#104 thanks @mstruebing)

### Changed

- Allows you to define paths for request_sms and request_phone_call (#108 thanks @dedene)

### Added

- Now sets a distinct user agent through the Authy gem (#110)

## [1.10.0] - 2018-09-26

### Changed

- Moves OneTouch approval request copy to locale file.

### Removed

- Demo app now lives in its own repo

## [1.9.0] - 2018-09-04

### Fixed

- Generated migration now includes version number for Rails 5

### Changed

- Removes Jeweler in favour of administering the gemspec by hand
- Removes demo app files from gem package

## [1.8.3] - 2018-07-05

### Fixed

- Fixes Ruby interpolation in HAML for onetouch (thanks @muan)
- Records Authy authentication after install verification (thanks @nukturnal)
- Forgets remember device cookie when disabling Authy (thanks @senekis)

### Changed

- Updated testing Rubies in CI

## Older releases

**_The following releases happened before the changelog was started. Some history will be added for clarity._**

## [1.8.2] - 2017-12-22

## [1.8.1] - 2016-12-06

## [1.8.0] - 2016-10-25

## [1.7.0] - 2015-12-22

## [1.6.0] - 2015-01-07

## [1.5.3] - 2014-06-11

## [1.5.2] - 2014-06-11

## [1.5.1] - 2014-04-24

## [1.5.0] - 2014-01-07

## [1.4.0] - 2013-12-17

## [1.3.0] - 2013-11-16

## [1.2.2] - 2013-09-04

## [1.2.1] - 2013-04-22

## [1.2.0] - 2013-04-22 [YANKED]

## [1.0.0] - 2013-04-10
