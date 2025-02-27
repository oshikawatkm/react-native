#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

set -e

# remove global prefix if it's already set
# the running shell process will choose a node binary and a global package directory breaks version managers
unset PREFIX

# Support Homebrew on M1
HOMEBREW_M1_BIN=/opt/homebrew/bin
if [[ -d $HOMEBREW_M1_BIN && ! $PATH =~ $HOMEBREW_M1_BIN ]]; then
  export PATH="$HOMEBREW_M1_BIN:$PATH"
fi

# Define NVM_DIR and source the nvm.sh setup script
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"

# Source nvm with '--no-use' and then `nvm use` to respect .nvmrc
# See: https://github.com/nvm-sh/nvm/issues/2053
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$HOME/.nvm/nvm.sh" --no-use
  nvm use 2> /dev/null || nvm use default
elif [[ -x "$(command -v brew)" && -s "$(brew --prefix nvm)/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix nvm)/nvm.sh" --no-use
  nvm use 2> /dev/null || nvm use default
fi

# Set up the nodenv node version manager if present
if [[ -x "$HOME/.nodenv/bin/nodenv" ]]; then
  eval "$("$HOME/.nodenv/bin/nodenv" init -)"
elif [[ -x "$(command -v brew)" && -x "$(brew --prefix nodenv)/bin/nodenv" ]]; then
  eval "$("$(brew --prefix nodenv)/bin/nodenv" init -)"
fi

# Set up the ndenv of anyenv if preset
if [[ ! -x node && -d ${HOME}/.anyenv/bin ]]; then
  export PATH=${HOME}/.anyenv/bin:${PATH}
  if [[ "$(anyenv envs | grep -c ndenv )" -eq 1 ]]; then
    eval "$(anyenv init -)"
  fi
fi

# Set up asdf-vm if present
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  # shellcheck source=/dev/null
  . "$HOME/.asdf/asdf.sh"
elif [[ -x "$(command -v brew)" && -f "$(brew --prefix asdf)/asdf.sh" ]]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix asdf)/asdf.sh"
fi

# Set up volta if present
if [[ -x "$HOME/.volta/bin/node" ]]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi
