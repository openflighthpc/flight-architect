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

### TL;DR

One-line installation - **note that you must verify you have the correct value
for** `alces_OS`:

```bash
curl -sL http://git.io/underware-installer | sudo alces_OS=el7 /bin/bash
```

### Basic installation

Underware is a system-level package and must be installed by the `root` user.

1. Become root.

   ```bash
   sudo -s
   ```

2. Set the `alces_OS` environment variable to match the distribution on which
   you are installing. Currently supported options are `el6` and `el7`:

     ```bash
     export alces_OS=el7
     ```
   
3. Invoke installation by piping output from `curl` to `bash`:

   ```bash
   curl -sL http://git.io/underware-installer | /bin/bash
   ```

   If you want to you can download the script first.  You might want to do this
   if you want to inspect what it's going to do, or if you're nervous about it
   being truncated during download:

   ```bash
   curl -sL http://git.io/underware-installer > /tmp/bootstrap.sh
   less /tmp/bootstrap.sh
   bash /tmp/bootstrap.sh
   ```

4. After installation, you can logout and login again in order to set up the
   appropriate shell configuration, or you can source the shell configuration
   manually:

   ```bash
   source /etc/profile.d/alces-underware.sh
   ```

### Advanced installation

For further installation techniques, please refer to [INSTALL.md](INSTALL.md).

## Usage

Underware is designed to be used both as a library by other Alces tools, and as
an independent tool in its own right. Documentation has not yet been written on
using it as a library; see below for documentation on using it as a tool.

Once installed and your shell configuration is sourced, you can access the
Underware tools via the `underware` command, e.g.:

```
[root@localhost ~]# underware
  NAME:

    underware

  DESCRIPTION:

    Tool for managing standard config hierarchy and template rendering under-lying Alces clusters and other Alces tools

  COMMANDS:

    asset        Manage the asset record files
    configure    Configure different aspects of this Underware installation
    each         Runs a command for a node(s)
    eval         Evaluate argument in context of `alces` namespace
    help         Display global or [command] help documentation
    layout       Manage the layout record files
    overview     Gives an overview of the configured groups
    plugin       View and manage activated plugins
    remove       Remove underware controlled files/ objects
    render       Render a given template
    view         View domain templating config, optionally in context for given node
    view-answers View configured answers

  GLOBAL OPTIONS:

    --strict
        Convert warnings to errors

    --quiet
        Suppress any warnings from being displayed

    -h, --help
        Display help documentation

    --version
        Display version information

    --trace
        Display backtrace when an error occurs
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
