# Aim

The internal paths are going to be revamped to allow rendering of multiple
clusters. This will allow any cluster specific configuration to live within
the `/var/lib` directory. This makes the internal `data` directory static
for reference purposes only.

# Requirements

1. Allow rendering of multiple independent clusters,
2. Store each cluster within the `/var/lib/underware/<cluster-name>`\*
3. Use the `<install-dir>/data` directory as a base reference only. It should
   never be edited w/o checking it into the repo
4. Update the `init` process to create a new repo from the `data`
5. All "content" type files should be cluster specific. This includes but is
   not limited to:
  1. `configs`
  2. `answers`
  3. `configure.yaml`
  4. `templates`
  5. `genders`
  6. `rendered`
  7. `build files`?
  8. `group_cache`

\* Stored within a underware `config.yaml` so they can be moved

# Refactoring

## Remove Configure Dependency on Nodeattr

Currently the genders file needs to be constantly re-rendered in order for the
configuration processes to work. This shouldn't be required as the configured
groups should already exist.

Instead the use of `nodeattr` or similar technologies is going to be removed
during the configuration. It will be replaced with a "cluster data"
configuration file which will hold all the data as `yaml`.

There will need to be compulsory questions during the group configure stage
which will setup this file correctly.

### Step 1: ClusterAttr class

This will be the abstraction to the node/group `yaml` file. It will act as the
replacement for `nodeattr`
*NOTE:* This object should not require access to `alces`

1. Create the `ClusterAttr` class with basic class abilities to expand and
   collapse node ranges
2. Replicate the basic `GroupCache` add functionality
3. Ensure the `orphan` group is preconfigured as the first (index 0) group
4. Create an `add_nodes` method, supporting node ranges using the `expand`
   method
5. Allow nodes to be added to `groups` with `add_nodes`
6. Prevent a node being added twice
7. `groups_hash` method that returns: `{ group_name => index }`

*NOTE*: The remove functionality can be skipped for this first pass

The yaml file should have the following structure:

```YAML
groups:
  - orphan # Must be the first group automagically (can the user change this?)
  - group1
  - group2
  -        # A blank index indicates a delet group (TBA)
  - group4

# The node names are not used as keys as this is nightmare to validate
# NOTE: A node can only appear once within the list
nodes:
  - nodes: collapsed_node_names
    groups: [primary_group, .. other groups ..]
```

### Step 2: Connect the ClusterAttr into the Namespace

At this point the cluster attributes need to be connected into the namespace.
This will temporarily prevent anything from being configured with underware

1. Create a mechanism for adding new groups/nodes within the specs
2. Add an instance of `ClusterAttr` onto the namespace
3. Build the list of `groups` using the `cluster_attr`
4. Update `orphan_list`
5. Remove `group_cache` off the namespace

### Step 3: Revamp the entire configuration process

The `Configurator` class is rather complicated as it is responsible for
creating groups in addition to asking questions and saving answers. Instead,
groups will be created within the commands themselves. This limits the
`Configurator` scope to only asking questions and saving answers

1. Remove all "group_cache" related code from the `Configurator`. Skipping
   any `command` specs that break as a result
2. Remove any orphan related code, this should be done within `configure node`
3. Create the `group` in `configure command`
4. Add mandatory questions to `configure group` (see below)
5. Update `ClusterAttr` based on mandatory questions in `configure group`
6. Create orphan node in `configure node` if required
5. Add mandatory question to `configure node`
6. Update `ClusterAttr` based on mandatory questions in `configure node`
5. Remove duplication due to mandatory questions

#### Mandatory Questions

As `configure.yaml` is becoming user content, `underware` can not rely on it
being correct. Instead there are going to be mandatory questions which will
always be asked.

As the `configure.yaml` file is consider an unsafe source, these questions will
not have defaults unless they have already been asked. This can be resolved in
the future (domain level mandatory questions?).

**Group:**
The group name to be created is give from the CLI, so this is fine. However
a group must contain `nodes` which may contain other groups. So the following
questions should be asked:

1. List of nodes within the `group` (e.g. blah)?
2. Additional groups these nodes belong to?

**Node:**
In this case the node has already been configured within a group. As such it
can only change which additional groups it belongs to.

1. Reask the additional groups question

#### Step 4: Render the genders file during template

The genders file is no longer used internally any more. However it might be used
eternally so it needs to rendered during the `template` stage

## Support Multiple Clusters

The existing `FilePath` method does not work with multiple clusters as it acts
as a global. However as everything relies on it, it can not be easily removed.

Instead the `FilePath` is going to go through a staged removal. This section
focuses on setting it up to work with a particular cluster in mind.

### Step 1: Copy the over the cluster data during init

The `init` process is responsible for creating a new cluster:

1. Accept a `cluster_identifier` from the CLI
2. Save it into `/var/lib/underware/etc/config.yaml`
3. Copy the `data` directory from `/v/l/u/<cluster_identifier>`
4. Forget that you have copied the data and continue using the original location
   of the files for the time being

### Step 2: Create the `DataPath` class

This is class will be the replacement to `FilePath` for all paths that are
cluster specific. It needs to be initialized with a cluster.

1. Create the class initializing it with a cluster
2. Create a `cache` class method that caches an instance with the current
   `cluster_indetifier`
3. Delegate missing methods on `FilePath` to the cached version of `DataPath`

### Step 3: Move all the cluster data paths across to `DataPath`

1. Move all cluster path methods onto `DataPath`, using delegation to handle
   the move
2. Update them to point to the new directory

### Step 4: Add a command to switch the current cluster

TBD

