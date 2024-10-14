# Git prompt for ZSH

Forked from [woefe/git-prompt.zsh](https://github.com/woefe/git-prompt.zsh).

## Changes

- Use ASCII characters.
- Show short commit hash.
- Show `=` sign when synced with upstream branch instead of static upstream symbol.
- Remove secondary prompt.
- Remove displaying of stash.
- Remove clean status symbol.
- Expect colors to be already loaded in shell environment.

## Dependencies

- git >= v2.11.0
- awk

## Usage

- Load the `git-prompt.zsh` file in your ZSH configuration file, e.g. `.zshrc`.
- Use `autoload -U colors && colors`.
- Add `'$(gitprompt)'` to your prompt.

