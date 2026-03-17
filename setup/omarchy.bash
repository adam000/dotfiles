#!/bin/bash


# Fail at the first command
set -e
# Fail if the first thing in the pipe fails
set -o pipefail
# Don't allow unset variables
set -u

sudo pacman -Syu

if ! [[ -d "~/.tmux" ]]; then
    if [[ -e ".tmux.conf" ]]; then
            mv .tmux.conf /tmp/tmux.conf
        fi

    ln -s src/dotfiles/tmux.conf .tmux.conf
    mkdir .tmux
    cd .tmux
    ln -s ../src/dotfiles/tmux/3grid 3grid
    ln -s ../src/dotfiles/tmux/autocomplete autocomplete
    ln -s ../src/dotfiles/tmux/default default
    cd ..
fi

if ! which tmux; then
    echo "Bootstrap phase 1/2: intall tmux"
    # Install tmux, then quit and tell the user to do it again in tmux
    # (got burned by disconnecting setups one to many times)
    sudo pacman -S tmux
    echo "Please run this script again in tmux (in case there's a disconnect)"
elif [[ -z "${TMUX-}" ]]; then
    echo "tmux is installed but you're not using it. If you really want to"
    echo "skip using tmux, run this command again prefixed by 'TMUX=skip'"
else
  echo "Bootstrap phase 2/2: install everything else"
  sudo pacman -S zsh htop tree

  # Clone dotfiles
  if ! [[ -e ~/src/dotfiles ]]; then
    mkdir ~/src
    cd ~/src
    git clone --depth=1 https://github.com/adam000/dotfiles.git
    cd ..
  fi

  # zsh
  if ! [[ -d .zsh ]]; then
    ln -s src/dotfiles/zshenv .zshenv
    mkdir .zsh
    cd .zsh
    ln -s ../src/dotfiles/zsh/zshrc .zshrc
    ln -s ../src/dotfiles/zsh/zshenv .zshenv
    ln -s ../src/dotfiles/zsh/zlogin .zlogin
    cd ..
  fi

  # zplug
  if ! [[ -d ".zplug" ]]; then
    export ZPLUG_HOME=$HOME/.zplug
    ZPLUG_VERSION=2.4.2
    git clone --depth=1 --branch $ZPLUG_VERSION https://github.com/zplug/zplug.git .zplug
  fi

  # tpm - tmux plugin manager
  if ! [[ -d plugins ]]; then
    mkdir plugins
    cd plugins
    git clone https://github.com/tmux-plugins/tpm.git
    cd ..
  fi

  # neovim - already installed, just use my config!
  mv ~/.config/nvim/init.lua /tmp/init.lua
  ln -s src/dotfiles/config/nvim/init.lua ~/.config/nvim/init.lua

  # git
  if ! [[ -e .gitconfig ]]; then
    ln -s src/dotfiles/gitconfig .gitconfig
    ln -s src/dotfiles/gitignore .gitignore
  fi

  # Need to change the shell to zsh
  echo "Now run: \`chsh -s \$(which zsh)\`"
  echo "And run \`nvim\` to install its plugins"
fi

# vim: set et sts=2 ts=2 tw=2 :
