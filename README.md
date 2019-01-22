# Alces Underware

Tool/library for managing standard config hierarchy and template rendering
under-lying Alces clusters and other Alces tools.

## Supported platforms

* Enterprise Linux 6 distributions: RHEL, CentOS, Scientific Linux (`el6`)
* Enterprise Linux 7 distributions: RHEL, CentOS, Scientific Linux (`el7`)

## Prerequisites

The install scripts handle the installation of all required packages from your
distribution and will install on a minimal base.  For Enterprise Linux
distributions installation of the `@core` and `@base` package groups is
sufficient.

## Installation

Underware uses ruby `2.4.1` with a corresponding version of `bundler`. It can
be installed from source using:

```
git clone https://github.com/alces-software/underware.git
cd underware
bundle install
```

## Usage

Underware is designed to be used both as a library by other Alces tools, and as
an independent tool in its own right. Documentation has not yet been written on
using it as a library; see below for documentation on using it as a tool.

The application can be invoked directly using the `bin` executable:
```
# bin/underware
  NAME:

    underware

  DESCRIPTION:

    Tool for managing standard config hierarchy and template rendering under-lying Alces
clusters and other Alces tools

... etc ...
```

### Creating a new cluster

A new generic cluster can be created using the `init` command. It will ask a few
questions about the cluster such as its name. Then it will generate an
one compute/ ten node cluster. 

```
# bin/underware init CLUSTER_IDENTIFIER
Name of the cluster (1/6)
> ?

... etc ..
```

The `CLUSTER_IDENTIFIER` is a label used to manage the cluster from the command
line. All commands that require a cluster input will use this identifier. It is
unrelated to the `cluster_name` which is set by the question. This is to allow
clusters with the same name but different configurations.

#### Creating a bare cluster

The `init` command can also create a cluster without any nodes using the
`--bare` flag. This skips the configuration of the `domain` and any `nodes`.
It does however create the cluster's basic directory structure· It further
configuration needs to use the `configure` commands.

```
# bin/underware init CLUSTER_IDENTIFIER --bare
(no questions asked)
```

## Documentation

- [Templating system](docs/templating-system.md)

## Contributing

Fork the project. Make your feature addition or bug fix. Send a pull request.
Bonus points for topic branches.

## Copyright and License

AGPLv3+ License, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2018 Alces Software Ltd.

Alces Underware is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your option)
any later version.

Alces Underware is made available under a dual licensing model whereby use of
the package in projects that are licensed so as to be compatible with AGPL
Version 3 may use the package under the terms of that license. However, if AGPL
Version 3.0 terms are incompatible with your planned use of this package,
alternative license terms are available from Alces Software Ltd - please direct
inquiries about licensing to
[licensing@alces-software.com](mailto:licensing@alces-software.com).
