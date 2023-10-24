#!/bin/bash

# Fail at the first command
set -e
# Fail if the first thing in the pipe fails
set -o pipefail
# Don't allow unset variables
set -u

sudo apt-get update
sudo apt-get upgrade -y

if ! which tmux; then
    echo "Bootstrap phase 1/2: intall tmux"
    # Install tmux, then quit and tell the user to do it again in tmux
    # (got burned by disconnecting setups one to many times)
    sudo apt-get install -y tmux
    ln -s src/dotfiles/tmux.conf .tmux.conf
    mkdir .tmux
    cd .tmux
    ln -s ../src/dotfiles/tmux/3grid 3grid
    ln -s ../src/dotfiles/tmux/autocomplete autocomplete
    ln -s ../src/dotfiles/tmux/default default
    cd ..
    echo "Please run this script again in tmux (in case there's a disconect)"
elif [[ -z "${TMUX-}" ]]; then
    echo "tmux is installed but you're not using it. If you really want to"
    echo "skip using tmux, run this command again prefixed by 'TMUX=skip'"
else
    echo "Bootstrap phase 2/2: install everything else"
    sudo apt-get install -y git openssh-server htop tree

    # Clone dotfiles
    mkdir ~/src
    cd ~/src
    git clone --depth=1 https://github.com/adam000/dotfiles.git
    cd ..

    # zsh
    sudo apt-get install -y zsh
    ln -s src/dotfiles/zshenv .zshenv
    mkdir .zsh
    cd .zsh
    ln -s ../src/dotfiles/zsh/zshrc .zshrc
    ln -s ../src/dotfiles/zsh/zshenv .zshenv
    ln -s ../src/dotfiles/zsh/zlogin .zlogin
    cd ..

    # tmux
    sudo apt-get install -y tmux
    ln -s src/dotfiles/tmux.conf .tmux.conf
    mkdir .tmux
    cd .tmux
    ln -s ../src/dotfiles/tmux/3grid 3grid
    ln -s ../src/dotfiles/tmux/autocomplete autocomplete
    ln -s ../src/dotfiles/tmux/default default

    # tpm - tmux plugin manager
    mkdir plugins
    cd plugins
    git clone https://github.com/tmux-plugins/tpm.git
    cd ..

    cd ..

    # vim
    sudo apt-get install -y vim
    ln -s src/dotfiles/vimrc .vimrc

    # git
    ln -s src/dotfiles/gitconfig .gitconfig
    ln -s src/dotfiles/gitignore .gitignore

    # Need to change the shell to zsh
    echo "Now run: chsh -s \$(which zsh)"
    echo "And run vim once if you want to install all the necessary plugins"
fi

