# Redesign of Command Invocation

Currently the old `BaseCommand` has become bloated with wildly different
priorities. At this point its functionality can't be scaled back without
breaking everything on top of it. Also there was some core design decisions
that make it hard to reuse the `command` classes.

Instead of trying adapting the old `BaseCommand`, it is time for wholesale
replacement of `BaseCommand`. The old `BaseCommand` will continue to be
maintained for the time being.

## Issues with current design

1. It requires a new command `class` for each command
2. Code has to be shared using `inheritance` or `mixins`
3. Commands can not be easily invoked without preforming the correct setup
4. `BaseCommand` uses instance variables to pass arguments (complexity)
5. It is tied to `Commander::Command::Options` reducing usability
6. It (use to) preforms configuration/ command logging
7. The handling of `alces`/`platform_option` is messy
8. The commands are tied to `Config` which acts as a global variables by proxy
9. `underware` logic is contained within the `BaseCommand`\*
10. Commands are super hard to test as they do a lot of setup
11. Dependency need to be rethought

\* `BaseCommand` being tied to `underware` isn't a bad thing by itself, but it
blurs the lines between the abstract concept of a "Command" and business logic

## NOTE: Maintaining backwards compatibility

At this stage it is vital that backwards compatibility is maintained with the
existing commands. Trying to convert all the commands up front is not worth
the development time.

The existing `CliHelper::Parser` is tied to using the `cli_helper/config.yaml`
and `BaseCommand`. Due to the coupling, the `Parser` is not going to form
part of the new command invocation. The `Parser` adds an additional level of
indirection, where the commands could have been defined in `cli.rb`.

Instead, the `Parser` will provide a mechanism for backwards compatibility with
the old commands. New commands will be added directly to the `cli.rb` file
with a new invocation mechanism which will be by-passed by the `parser`.

## Core Components

The `BaseCommand` does to many thing that make it impossible to reuse. Instead
it will be broken into two components: `Runner` and `Command`

### Runner

Two major issue with the `BaseCommand` is it tied `Commander` and `Config`. By
being tied to `Commander`, reusing it requires jumping through hoops in order
to create the `args` and `opts` correctly. Secondly `BaseCommand` does `Config`
setup making it extremely difficult to test under different environments.
NOTE: Inherited classes also reference `Config` directly :(

The fix is to add a `Runner` class(/library/concept?). Its purposes is to act
as the adaptation layer between the `CLI` library (`Commander`) and the
commands.

It will be responsible for taking the `commander` inputs `args`, `opts` and
adapting to calling public methods on `Command` (see below).

Responsibilities:
1. Convert the `Commander` inputs to method calls on `Commands`
2. Decouple the `Commands` from `Commander`
3. Create an instance of a `Config` which is to be used with the `Command`
4. Hide `Commander` `global_options` from Commands\*
5. Handle the logging setup and log the command itself
6. Catching `Interrupt` so it doesn't print the trace log (`Commander` default)
7. Catching and logging fatal errors
8. Anything else that is deemed to be "setup" instead of running

\* Global options are a pain because it means every commander needs to check for
there existence and modify its behaviour accordingly. Typically the only reason
for a global is to modify some form of configuration. So instead of exposing the
global to the commands, it can be stored within the instance of a `Config`.

### Command

Now that the setup tasks have been extracted, the purpose of the `Command`
classes becomes clear. They are responsible for preforming a "task". They
should not change the configuration of the process itself.

`Commands` are not responsible for `fatal` errors or interrupt (normally).
They may however catch handled errors or provide custom interrupt support.
Caution should be given when catching errors as this can reduce re-usability.
Fatal errors should always be handled by the `Runner` even if this means
catching and (re)raising a different error.

The `public` methods on the `Command` represent commands to the `CLI`. The
`*args` and `**options` inputs into method should used to pass arguments
and option flags. `option` defaults should be handled in some logical manner
as they could be setup at the `CLI` or `Command` level.

Using the `public` methods will allow commands to be directly tested within
the specs. It also allows common code to be shared as `private` methods
as an alternative to `inheritance`/`mixins`.

Finally each `Command` will be initialized with an instance of `Config`. This
will allow commands to be ran with different configuration. This is already
required in the `init` command as it switches the cluster.

#### NOTE: Usage of the `Config`

Just because the `Command` is initialized with the `Config` doesn't mean the
rest of the code base will use it. The prime examples for this is `FilePath`
and `UnderwareLog`. Both of these library classes require a `Config` to
modify there behaviour.

The `UnderwareLog` is easily fixed as its setup is being integrated into the
command execution life cycle. Also a stale config isn't the end of the world
when it comes to the logging.

`FilePath` is the main culprit as it will directly affect the execution of
any code built on top of it (aka EVERYTHING). Despite this fact, `Command`
should not care about this as `FilePath` has been deprecated and should be
removed. It will be the responsibility of the calling class to make sure
`FilePath` has been configured correctly.

To prevent further coupling to `Config` as a global, the `cache` method
should be removed. Instead the `UnderwareLog` and `FilePath` should be directly
configured with a `config`. This way it is a bit clearer which config they
operate on.

