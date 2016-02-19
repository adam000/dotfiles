# First, get utils
[[ -e "$HOME/.bashutils" ]] && source ~/.bashutils

swap() {
    if (( $# == 2 )); then
        mv "$1" /tmp/
        mv "$2" "`dirname $1`"
        mv "/tmp/`basename $1`" "`dirname $2`"
    else
        echo "Usage: swap <file1> <file2>"
        return 1
    fi
}

# colors
RED="\[\e[31m\]"
GRE="\[\e[32m\]"
YEL="\[\e[33m\]"
BLU="\[\e[34m\]"
PUR="\[\e[35m\]"
CYA="\[\e[36m\]"
WHI="\[\e[37m\]"
NUL="\[\e[0m\]"

# my custom prompt
export PS1="\n[\`FOO=\$?; if [ ! \$FOO = 0 ]; then echo -n ${RED}; else echo -n ${GRE}; fi; echo -n \"\t${NUL}] \"; if [ ! \${FOO} = 0 ]; then echo \"${RED}E:\$FOO${NUL} \"; fi\`${PUR}(${NUL}\h${PUR})${NUL} ${CYA}\w${NUL}\n$ "

# history options
HISTSIZE=200
HISTCONTROL=ignoreboth

#############
## EXPORTS ##
#############

export EDITOR=vim

if command_exists mvim; then
    export VISUAL=mvim
else
    export VISUAL=vim
fi

export CLICOLOR=1

#############
## ALIASES ##
#############

# computer machines
alias vogon="ssh ahintz@vogon.csc.calpoly.edu"
alias xeon="ssh ahintz@xeon.csc.calpoly.edu"
alias unix1="ssh ahintz@unix1.csc.calpoly.edu"
alias unix2="ssh ahintz@unix2.csc.calpoly.edu"
alias unix3="ssh ahintz@unix3.csc.calpoly.edu"
alias unix4="ssh ahintz@unix4.csc.calpoly.edu"
alias sparc01="ssh ahintz@sparc01.csc.calpoly.edu"
alias sparc02="ssh ahintz@sparc02.csc.calpoly.edu"

# shortcut commands
alias xsera="cd ~/scm/git/xsera"
alias lit="clear; ls; echo -----------------------------------; git status"
alias cit="clear; git status"

alias ll="ls -la"

alias wme="w | egrep --color=always '^|`whoami`.*$'"

if [ -d ~/scm/git/dotfiles ]; then
    alias dotfiles="cd ~/scm/git/dotfiles"
fi

# typos
alias sl="ls -F"

# OS-X-Specific commands
if [ ! -z "`echo $OSTYPE | grep darwin`" ]; then
    alias xc="open -a xcode"
    alias chrome="open -a google\ chrome"
    # show file in Finder
    alias show="open -R"
    # Fun stuff
    alias newinst="open -n -a"
    alias blend="open -a Blender"
fi

# OP commands
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."

# My editor is vim
set -o vi
# A fun little touch
alias :q="exit"

# git stuffs
st()
{
  if git rev-parse --git-dir > /dev/null 2>&1; then
    git branch | grep "\*"
    git status -s
    if ! git diff --quiet; then
      echo -e "+\t-\tfile"
      git diff --numstat | cat
    fi
  else
    return -1
  fi;
}

alias ci="git commit -a -m"

# Sourcing other file(s)

if [[ -e ~/.localbashrc ]]; then
    . ~/.localbashrc
fi

# bashrc loaded. Set the variable

export BASHRC_LOADED=0

# vim: set ts=2 sw=2:
