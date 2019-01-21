# Issue

Previously the `ssh-key` pair was generated at install time, for the single
cluster that was being configured. This doesn't work for multiple clusters
however and the installer is being binned.

Instead the `ssh` key needs to be handled when the cluster is initialized

# Requirements

1. The `ssh-key` pair shouldn't have to exist in advance. It should be handled
   seamlessly
2. Keys can be shared between `clusters` in a one-many relationship
3. The key should be set as part of the `init` process with a default setting
4. There needs to be full CRUD for managing the keys

# Solution

## Step 1: Key Store + Abstraction

The keys should be stored separately to the `clusters` data. This means a single
key can be used multiple times.

As keys are a separate concept to cluster related concepts, they will also have
a `KeyPair` abstraction. This abstraction will implement the `public_key` and
`private_key` methods. These will have corresponding methods for determining
the file path. 

The heavy lifting associated with generating keys can be abstracted away with
`OpenSSL::PKey::RSA`.

NOTE: The `DataPath` objects has `public_key` and `private_key` methods as well.
These methods will likely be removed? TBA

1. Create the `KeyPair` abstraction object
2. Implement the required path methods (see below)
3. Implement a `generate` class method for creating a new key pair

### Key Store directory structure

The keys should be stored within the content directory. This will make the
independent from `underware` core files. The directory structure should be
as follows. This will allow keys to be added manually to the file structure
without having to update a manifest file.

### Simple file structure
The file structure below will allow multiple keys to be stored and retrieved
by name alone.

```
/var/lib/underware/keys/<key-name>/id_rsa # Private Key
/var/lib/underware/keys/<key-name>/id_rsa.pub # Public Key
```

### Question: Do we need the public key?

Once the `private_key` as been specified, it's possible to generate the
`public_key` automagically. This would remove the need to store the public
independently, which simplifies the directory structure to bellow. It also
prevents public and private keys from becoming out of sync:

Then if there is a use case for public keys without private, then the key
name would be: `public/<public-key-name>`

```
# Private key with an implicit public key
/v/l/u/keys/<key-name>


# Public key without a private key partner
/v/l/u/keys/public/<public-name> # key-name = 'public/<public-name>'
```

## Step 2: Assign clusters to a key

Previously there was a path to the key directly, this is not going to be
supported moving forward. Instead the (probably `Domain`?) namespace will
access the keys content directly. This keeps the path obfuscated from the
user. This is not a security precaution, but instead allows for greater
flexibility on how keys are stored.

There is now a role for a "cluster_config". This will store configuration
data about individual clusters that `underware` can trust. It needs to be
auto generated if missing with reasonable defaults.

1. Define `cluster_config` path on `DataPath` to some reasonable location
2. Create the `ClusterConfig` abstraction using `ConfigLoader`
3. Define a `key_name` method setable from the config with a default
4. Create a `keys` method that returns a `KeyPair` object using the name
5. `keys` should error if it is missing, the config should not generate keys
6. Hook the keys into the namespaces

By storing the `ClusterConfig` with the cluster, it can be easily deleted
with the cluster as well. This prevents other 

## Step 3: Hook the components into the `init`

The `init` command is responsible for creating new clusters and thus has
some responsibility for creating new keys. It should do this explicitly
or refuse to create the cluster.

1. Add a `--key-pair` flag to the CLI, if it is missing, then fall back
   on `ClusterConfig` default value
2. If the key doesn't exists prompt the user if they wish to generate it
3. Exit if the user does not wish to create the key, clusters must have a key
4. Update the `ClusterConfig` even if it's the default. This will statically
   set it for the cluster

## Step 4: Key management

There needs to be a full CRUD stack for creating/ destroying keys. This should
be developed using a similar UI style to the clusters (TBA)

