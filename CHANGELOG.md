# Change Log

All notable changes to this project will be documented in this file.

## Unreleased

## [alpha-01] - 2018-10-15

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
