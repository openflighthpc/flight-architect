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

Flight Runway provides the Ruby environment and command-line helpers for running openflightHPC tools.

To install Flight Runway, see the [Flight Runway installation docs](https://github.com/openflighthpc/flight-runway#installation). 

These instructions assume that `flight-runway` has been installed from the openflightHPC yum repository and [system-wide integration](https://github.com/openflighthpc/flight-runway#system-wide-integration) enabled.

Install Flight Architect:

```
[root@myhost ~]# yum -y install flight-architect
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
    <snip>
```
