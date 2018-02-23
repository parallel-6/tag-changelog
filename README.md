# tag-changelog

Tool to generate changelog based on Parallel6 specs

#### NAME
    tag-changelog - Tool to generate changelog based on Parallel6 specs

#### SYNOPSIS
    tag-changelog [global options] command [command options] [arguments...]

#### VERSION
    0.0.1

#### GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

#### COMMANDS
    generate - Generate changelog and write to CHANGELOG.md (default).
    help     - Shows a list of commands or help for one command


## Usage

All you need to do is cd into project's directory where you need to generate
changelog and run:

```
$ tag-changelog generate
```

This will execute the `generate` command with the default params. Please see below
for a list of options you can pass to the command.

#### generate command options
    -c, --config=file         - Configuration file to categorize commit messages in YML format. Must be an absolute path. (default: gem's own config.yml)
    -d, --dir=directory       - Git repository directory (must be an absolute path). Defaults to working directory. (default: current working directory)
    -f, --filter=regexp       - Regexp to categorize commits from git log. (default: (\[+\s?+[cfbhrCFBHR]{1}+\s?+\]))
    --[no-]group              - Group commit messages in categories (defined in configuration file). (default: enabled)
    --[no-]head               - Include HEAD as a tag. Useful when new tag is not released yet (as a preview). Can be disabled. (default: enabled)
    -o, --output=file         - Output destination. (default: CHANGELOG.md)
    --[no-]pull-requests-only - Only list merged pull requests. Can be disabled to list all commits. (default: enabled)
    -s, --skip=tag_list       - Skip tags (may be used more than once, default: none)
