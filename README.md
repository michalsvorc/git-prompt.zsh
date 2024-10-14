# Git prompt for ZSH

Forked from [woefe/git-prompt.zsh](https://github.com/woefe/git-prompt.zsh).

## Changes

**Added**:
- show short commit hash
- show `=` sign when synced with upstream branch

**Changed**:
- use ASCII characters by default

**Removed**:
- stash information
- secondary prompt
- clean status symbol
- shell colors settings

## Dependencies

- git >= v2.11.0
- awk

## Usage

- Load the `git-prompt.zsh` file in your ZSH configuration file, e.g. `.zshrc`.
- Use `autoload -U colors && colors`.
- Add `'$(gitprompt)'` to your prompt.

