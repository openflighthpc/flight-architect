# Installing Flight Architect

## Generic

Flight Architect requires a recent version of `ruby` (2.5.1<=) and `bundler`.
The following will install from source using `git`:
```
git clone https://github.com/openflighthpc/flight-architect.git
cd flight-architect
bundle install
```

The entry script is located at `bin/architect`

## Installing with Flight Runway

Flight Runway (and Flight Tools) provides the Ruby environment and command-line helpers for running openflightHPC tools.

To install Flight Runway, see the [Flight Runway installation docs](https://github.com/openflighthpc/flight-runway#installation>) and for Flight Tools, see the [Flight Tools installation docs](https://github.com/openflighthpc/openflight-tools#installation>).

These instructions assume that `flight-runway` and `flight-tools` have been installed from the openflightHPC yum repository and [system-wide integration](https://github.com/openflighthpc/flight-runway#system-wide-integration) enabled.

Integrate Flight Architect to runway:

```
[root@myhost ~]# flintegrate /opt/flight/opt/openflight-tools/tools/flight-architect.yml
Loading integration instructions ... OK.
Verifying instructions ... OK.
Downloading from URL: https://github.com/openflighthpc/flight-architect/archive/master.zip ... OK.
Extracting archive ... OK.
Performing configuration ... OK.
Integrating ... OK.
```

Flight Architect is now available via the `flight` tool::

```
[root@myhost ~]# flight architect
  NAME:

    flight architect

  DESCRIPTION:

    Tool for managing standard config hierarchy and template rendering under-lying Alces clusters and other Alces tools

  COMMANDS:

    cluster      Initialize, list, switch, and delete cluster configurations
    configure    Manage the cluster and node configurations
    each         Runs a command for a node(s)
    <snip>
```
