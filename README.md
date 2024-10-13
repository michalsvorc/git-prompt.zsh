# Git prompt for ZSH

Forked from [woefe/git-prompt.zsh](https://github.com/woefe/git-prompt.zsh).

## Changes

- Use ASCII characters.
- Show "=" sign when synced with upstream branch instead of static upstream symbol.
- Remove displaying of stash.
- Remove clean status symbol.

## Dependencies

- Git >= v2.11.0
- awk

## Usage

Load the `git-prompt.zsh` file in your ZSH configuration file, e.g. `.zshrc`.
Use `'$(gitprompt)'` to get the Git prompt.

