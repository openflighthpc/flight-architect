# Change Log

All notable changes to this project will be documented in this file.

## Unreleased

## [0.4.0] - 2018-12-07

- Made various initial changes as part of getting Underware ready to be used as
  a product rather than an internal tool only.
- Removed concept of Underware 'repo', all Underware content now lives in
  Underware itself within `data` directory
  (https://github.com/alces-software/underware/pull/26).
- Changed single `render` command to `render` group of commands (`render
  domain`/`render group`/`render node`), to allow easily rendering against any
  namespace (https://github.com/alces-software/underware/pull/27).
- Added concept of 'specializing' namespaces for a platform, where the platform
  config will also be included and merged in with the regular namespace config
  hierarchy; also added `--platform` option to `render` commands to render
  against these specialized namespaces
  (https://github.com/alces-software/underware/pull/29 and
  https://github.com/alces-software/underware/pull/30).
- Added `template` command, to render all Underware templates for all platforms
  and namespaces (https://github.com/alces-software/underware/pull/30).

## [0.3.0] - 2018-10-31

- Made a few minor tweaks to correct some incorrect things in the latest
  Underware Gem when used by Metalware.

## [0.2.0] - 2018-10-30

- Converted Underware into a Gem capable of being used from Metalware, while
  still being able to be used as an independent tool in its own right.
- Further significantly cut down, adapted, or reorganised the things to be
  included in Underware, as part of the process of adapting Metalware to use
  the Underware Gem.

## [alpha-01 / 0.1.0] - 2018-10-15

- Initial Underware alpha release, adapted from Metalware as of
  https://github.com/alces-software/metalware/commit/5aa35770
  (https://github.com/alces-software/underware/pull/1).
- The following commands adapted from the Metalware versions are initially
  available: `asset`, `configure`, `each`, `eval`, `help`, `layout`,
  `overview`, `plugin`, `remove`, `render`, `repo`, `view`, and `view-answers`
- Underware is installed in a similar way to Metalware but with
  `/opt/underware` as the standard installation directory, and all Underware
  data is stored to/accessed from `/var/lib/underware`.
- The Underware namespace has been tweaked from the latest Metalware namespace
  as follows:
  -  `alces.hunter` is no longer an available part of the namespace;
  - any arbitrary data file `foo.yaml` can now be placed at
    `/var/lib/underware/data/foo.yaml`, and the data within this can then be
    accessed similarly to any other part of the namespace like
    `alces.data.foo.bar`.
