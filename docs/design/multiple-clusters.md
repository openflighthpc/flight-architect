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

# Issues

The following issues will need to resolved before moving forward:

1. A custom version of `nodeattr` is installed with a hard coded path to:
   `/var/lib/underware/rendered/system/genders`
2. The `FilePath` class stores all the different types of paths. However there
   are now a subset of paths with specific cluster-ish behaviour
3. Files do not have `Object` abstractions and are accessed in multiple places
   NOTE: This means the path needs to be determined independently
4. Paths are going to be `cluster` specific OR relative to the `data` directory
5. Paths for multiple clusters need to be generated within the same process
   NOTE: This is to allow `copy` functionality and prevents global vars
6. The clustername is currently a `config/answer` value making a circular
   reference between the file path and its content

# Ideal Solution

Ideally each file type would have an object abstraction. For example, an
`Answer` model would be responsible for answer files and similarly for a
`Config` model etc.

This would allow a mixin that implements the `ClusterPath` functionality. As
each class is responsible for its own files, it doesn't mater if the path
changes on a cluster basis. As long the `Answer` class can find its answers,
anything that references `Answers` will continue working.

The catch is nothing has been designed in this manner. Files are accessed in
multiple locations as a hold over from the initial templater. Implementing this
would require rebuilding the core internals of the `Namespace`

# Compromised Solution

The core issues atm is that paths are essentially global. They are all accessed
with methods like `FilePath.domain_answers`. This leaves little room to
manoeuvre when it comes to generating cluster specific paths.

The core component that needs to change is the `internal_data_dir` is going to
become cluster specific. However this can not be done with a global variable as
this will prevent generating paths for multiple clusters within the same
process. Doing so would kill all ability to `copy` cluster files.

Following a similar design pattern, there needs to be a `Content::Path` like
object. It will be initialized with the relevant cluster
(e.g. `Content::Path.new(cluster: cluster_name)`). This will make all its paths
cluster specific and solves the global issue.

The relevant classes can then determine the file path as long as they have
access to the clustername. This can be resolved by storing it on the main
`alces` namespace.

# Implementation

0. Wrap `alces.domain.config.clustername` as `alces.clustername`
1. Create the `Content::Path` object with the `cluster` initialization
2. Move all the relevant paths onto `Content::Path` ignoring the cluster
  1. Add a path to `Content::Path` delegating it back to `FilePath`
  2. Replaces all references to the `FilePath.method` to `Content::Path`
  3. Implement the method on `Content::Path` ignoring the cluster
  4. Remove the method off `FilePath`
  5. Repeat relevant steps for the remaining paths
3. Update the `NodeattrInterface` to use cluster specific paths
  1. Create a `NodeattrInterface` instance class that is initialized with
   the file path
  2. Delegate the instance methods to the class methods
  3. Change all external references to the class to the instance
  4. Move the class methods onto the instance
  5. Call `nodeattr` with a `-f file` flag pointing to the correct path
4. Add scoping to specify a current cluster so it doesn't need to be
   include with every `CLI` command.
  1. Add a change scope command which takes a simple string input
  2. Initialize the `alces` namespace with this input
  3. Use this input to in `alces.clustername` 
  4. Remove the `clustername` question from configuration
5. Update the `Content::Path` method to point all the paths to the cluster
   specific
   NOTE: This will require manually copying some of the `data` directory to
   `var` so it continues to work. This will break all the `specs` which need
   to be resolved
6. Add a `Content::Path.new` method that points to the `data` directory
7. Update the `init` command to copy the files from `data` into `var`

