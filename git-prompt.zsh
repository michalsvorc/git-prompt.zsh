# git-prompt.zsh -- a lightweight git prompt for zsh.
# Copyright © 2024 Wolfgang Popp
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Modified by Michal Svorc
# See [README](https://github.com/michalsvorc/git-prompt.zsh/blob/master/README.md)
# for list of changes.

# Settings
: "${ZSH_GIT_PROMPT_SHOW_UPSTREAM="symbol"}"
: "${ZSH_GIT_PROMPT_SHOW_TRACKING_COUNTS="1"}"
: "${ZSH_GIT_PROMPT_SHOW_LOCAL_COUNTS="1"}"
: "${ZSH_GIT_PROMPT_NO_ASYNC=""}"
: "${ZSH_GIT_PROMPT_FORCE_BLANK=""}"
: "${ZSH_GIT_PROMPT_AWK_CMD=""}"

# Theming
: "${ZSH_THEME_GIT_PROMPT_PREFIX="["}"
: "${ZSH_THEME_GIT_PROMPT_SUFFIX="] "}"
: "${ZSH_THEME_GIT_PROMPT_SEPARATOR="|"}"
: "${ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg[cyan]%}:"}"
: "${ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg[magenta]%}"}"
: "${ZSH_THEME_GIT_PROMPT_UPSTREAM_NO_TRACKING=""}"
: "${ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX="%{$fg[red]%}(%{$fg[yellow]%}"}"
: "${ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX="%{$fg[red]%})"}"
: "${ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[yellow]%}<"}"
: "${ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[yellow]%}>"}"
: "${ZSH_THEME_GIT_PROMPT_SYNCED="%{$fg[yellow]%}="}"
: "${ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}x"}"
: "${ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}+"}"
: "${ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}+"}"
: "${ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}?"}"
: "${ZSH_THEME_GIT_PROMPT_COMMIT_HASH_PREFIX="%{$fg[white]%}(%{$fg[cyan]%}"}"
: "${ZSH_THEME_GIT_PROMPT_COMMIT_HASH_SUFFIX="%{$fg[white]%})"}"

# Disable promptinit if it is loaded
(( $+functions[promptinit] )) && {promptinit; prompt off}

# Allow parameter and command substitution in the prompt
setopt PROMPT_SUBST

# Find an awk implementation
# Prefer nawk over mawk and mawk over awk
(( $+commands[mawk] ))  &&  : "${ZSH_GIT_PROMPT_AWK_CMD:=mawk}"
(( $+commands[nawk] ))  &&  : "${ZSH_GIT_PROMPT_AWK_CMD:=nawk}"
                            : "${ZSH_GIT_PROMPT_AWK_CMD:=awk}"

    _zsh_git_prompt_git_cmd() {
        command git --no-optional-locks status --branch --porcelain=v2 2>&1 \
            || echo "fatal: git command failed"
    }
function _zsh_git_prompt_git_status() {
    emulate -L zsh
    _zsh_git_prompt_git_cmd | $ZSH_GIT_PROMPT_AWK_CMD \
        -v PREFIX="$ZSH_THEME_GIT_PROMPT_PREFIX" \
        -v SUFFIX="$ZSH_THEME_GIT_PROMPT_SUFFIX" \
        -v SEPARATOR="$ZSH_THEME_GIT_PROMPT_SEPARATOR" \
        -v DETACHED="$ZSH_THEME_GIT_PROMPT_DETACHED" \
        -v BRANCH="$ZSH_THEME_GIT_PROMPT_BRANCH" \
        -v UPSTREAM_TYPE="$ZSH_GIT_PROMPT_SHOW_UPSTREAM" \
        -v SHOW_TRACKING_COUNTS="$ZSH_GIT_PROMPT_SHOW_TRACKING_COUNTS" \
        -v SHOW_LOCAL_COUNTS="$ZSH_GIT_PROMPT_SHOW_LOCAL_COUNTS" \
        -v UPSTREAM_SYNCED="$ZSH_THEME_GIT_PROMPT_SYNCED" \
        -v UPSTREAM_NO_TRACKING="$ZSH_THEME_GIT_PROMPT_UPSTREAM_NO_TRACKING" \
        -v UPSTREAM_PREFIX="$ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX" \
        -v UPSTREAM_SUFFIX="$ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX" \
        -v BEHIND="$ZSH_THEME_GIT_PROMPT_BEHIND" \
        -v AHEAD="$ZSH_THEME_GIT_PROMPT_AHEAD" \
        -v UNMERGED="$ZSH_THEME_GIT_PROMPT_UNMERGED" \
        -v STAGED="$ZSH_THEME_GIT_PROMPT_STAGED" \
        -v UNSTAGED="$ZSH_THEME_GIT_PROMPT_UNSTAGED" \
        -v UNTRACKED="$ZSH_THEME_GIT_PROMPT_UNTRACKED" \
        -v COMMIT_HASH_PREFIX="$ZSH_THEME_GIT_PROMPT_COMMIT_HASH_PREFIX" \
        -v COMMIT_HASH_SUFFIX="$ZSH_THEME_GIT_PROMPT_COMMIT_HASH_SUFFIX" \
        -v RC="%{$reset_color%}" \
        '
            BEGIN {
                ORS = "";

                fatal = 0;
                oid = "";
                head = "";
                upstream = "";
                ahead = 0;
                behind = 0;
                untracked = 0;
                unmerged = 0;
                staged = 0;
                unstaged = 0;
            }

            function prompt_element(prefix, content, suffix) {
                print(prefix);
                gsub("%", "%%", content);
                print(content);
                print(suffix);
                print(RC);
            }

            function count_element(prefix, count, show_count) {
                content = "";
                if (show_count) {
                    content = count;
                }
                if (count > 0) {
                    prompt_element(prefix, content);
                }
            }

            function local_element(prefix, count) {
                count_element(prefix, count, SHOW_LOCAL_COUNTS)
            }

            function tracking_element(prefix, count) {
                count_element(prefix, count, SHOW_TRACKING_COUNTS)
            }

            $1 == "fatal:" {
                fatal = 1;
            }

            $2 == "branch.oid" {
                oid = $3;
            }

            $2 == "branch.head" {
                head = $3;
            }

            $2 == "branch.upstream" {
                upstream = $3;
            }

            $2 == "branch.ab" {
                ahead = $3;
                behind = $4;
            }

            $1 == "?" {
                ++untracked;
            }

            $1 == "u" {
                ++unmerged;
            }

            $1 == "1" || $1 == "2" {
                split($2, arr, "");
                if (arr[1] != ".") {
                    ++staged;
                }
                if (arr[2] != ".") {
                    ++unstaged;
                }
            }

            END {
                if (fatal == 1) {
                    exit(1);
                }

                prompt_element(PREFIX);

                if (head == "(detached)") {
                    prompt_element(DETACHED, substr(oid, 0, 7));
                } else {
                    prompt_element(BRANCH, head);
                }

                # commit hash
                commit_hash = substr(oid, 1, 7)
                prompt_element(COMMIT_HASH_PREFIX, commit_hash, COMMIT_HASH_SUFFIX);

                if (upstream == "") {
                    prompt_element(UPSTREAM_NO_TRACKING);
                } else if (UPSTREAM_TYPE == "symbol" && behind == 0 && ahead == 0) {
                    prompt_element(UPSTREAM_SYNCED);
                } else if (UPSTREAM_TYPE == "full") {
                    prompt_element(UPSTREAM_PREFIX, upstream, UPSTREAM_SUFFIX);
                }

                tracking_element(BEHIND, behind * -1);

                tracking_element(AHEAD, ahead * 1);

                if (unmerged == 0 && staged == 0 && unstaged == 0 && untracked == 0) {
                    # clean
                } else {
                    prompt_element(SEPARATOR);
                }

                local_element(UNMERGED, unmerged);

                local_element(STAGED, staged);

                local_element(UNSTAGED, unstaged);

                local_element(UNTRACKED, untracked);

                prompt_element(SUFFIX);
            }
        '
}

# The async code is taken from
# https://github.com/zsh-users/zsh-autosuggestions/blob/master/src/async.zsh

zmodload zsh/system

function _zsh_git_prompt_async_request() {
    typeset -g _ZSH_GIT_PROMPT_ASYNC_FD _ZSH_GIT_PROMPT_ASYNC_PID

    # If we've got a pending request, cancel it
    if [[ -n "$_ZSH_GIT_PROMPT_ASYNC_FD" ]] && { true <&$_ZSH_GIT_PROMPT_ASYNC_FD } 2>/dev/null;
    then

        # Close the file descriptor and remove the handler
        exec {_ZSH_GIT_PROMPT_ASYNC_FD}<&-
        zle -F $_ZSH_GIT_PROMPT_ASYNC_FD

        # Zsh will make a new process group for the child process only if job
        # control is enabled (MONITOR option)
        if [[ -o MONITOR ]]; then
            # Send the signal to the process group to kill any processes that may
            # have been forked by the suggestion strategy
            kill -TERM -$_ZSH_GIT_PROMPT_ASYNC_PID 2>/dev/null
        else
            # Kill just the child process since it wasn't placed in a new process
            # group. If the suggestion strategy forked any child processes they may
            # be orphaned and left behind.
            kill -TERM $_ZSH_GIT_PROMPT_ASYNC_PID 2>/dev/null
        fi
    fi

    # Fork a process to fetch the git status and open a pipe to read from it
    exec {_ZSH_GIT_PROMPT_ASYNC_FD}< <(
        # Tell parent process our pid
        builtin echo $sysparams[pid]

        _zsh_git_prompt_git_status
    )

    # There's a weird bug here where ^C stops working unless we force a fork
    # See https://github.com/zsh-users/zsh-autosuggestions/issues/364
    command true

    # Read the pid from the child process
    read _ZSH_GIT_PROMPT_ASYNC_PID <&$_ZSH_GIT_PROMPT_ASYNC_FD

    # When the fd is readable, call the response handler
    zle -F "$_ZSH_GIT_PROMPT_ASYNC_FD" _zsh_git_prompt_callback
}

# Called when new data is ready to be read from the pipe
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_ZSH_GIT_PROMPT_STATUS_OUTPUT=""
function _zsh_git_prompt_callback() {
    emulate -L zsh
    local old_primary="$_ZSH_GIT_PROMPT_STATUS_OUTPUT"
    local fd_data
    local -a output

    if [[ -z "$2" || "$2" == "hup" ]]; then
        # Read output from fd
        fd_data="$(cat <&$1)"
        output=( ${fd_data} )
        _ZSH_GIT_PROMPT_STATUS_OUTPUT="${output[1]}"

        if [[ "$old_primary" != "$_ZSH_GIT_PROMPT_STATUS_OUTPUT" ]]; then
            zle reset-prompt
            zle -R
        fi

        # Close the fd
        exec {1}<&-
    fi

    # Always remove the handler
    zle -F "$1"

    # Unset global FD variable to prevent closing user created FDs in the precmd hook
    unset _ZSH_GIT_PROMPT_ASYNC_FD
}

function _zsh_git_prompt_precmd_hook() {
    if [[ -n "$ZSH_GIT_PROMPT_FORCE_BLANK" ]]; then
        _ZSH_GIT_PROMPT_STATUS_OUTPUT=""
    fi
    _zsh_git_prompt_async_request
}

if (( $+commands[git] )); then
    if [[ -z "$ZSH_GIT_PROMPT_NO_ASYNC" ]]; then
        autoload -U add-zsh-hook \
            && add-zsh-hook precmd _zsh_git_prompt_precmd_hook

        function gitprompt() {
            echo -n "$_ZSH_GIT_PROMPT_STATUS_OUTPUT"
        }
    else
        function gitprompt() {
            _zsh_git_prompt_git_status
        }
    fi
else
    function gitprompt() { }
fi
