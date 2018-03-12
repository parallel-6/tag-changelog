# tag-changelog

Tool to generate changelog based on Parallel6 specs, reading from git history.

#### NAME
    tag-changelog - Tool to generate changelog based on git history.

#### SYNOPSIS
    tag-changelog [global options] command [command options] [arguments...]

#### VERSION
    1.0.0

#### GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

#### COMMANDS
    generate - Generate changelog and write to CHANGELOG.md (default).
    help     - Shows a list of commands or help for one command

## Installation

```
$ gem install tag-changelog
```

## Usage

All you need to do is cd into project's directory where you need to generate
changelog and run:

```
$ tag-changelog generate
```

This will execute the `generate` command with the default params.
Please see below for a list of options you can pass to the command.

#### generate command options
    -d, --dir=directory       - Git repository directory (must be an absolute path). Defaults to working directory. (default: current working directory)
    -o, --output=file         - Output destination. (default: CHANGELOG.md)


## Customizing your changelog
All you need to do is to create a `.tag_changelog.yml` file in the root of the
git repository directory to override the default configuration from this gem.

Please take a look at the [default configuration yml file here](lib/tag_changelog/templates/config.yml) to learn more about the available options. You do not need to add all keys in your
custom `yml` file, only those you're interested in overriding.
