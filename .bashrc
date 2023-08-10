#!/bin/bash

#
# minishell - minimal bashrc config
#


#
# environment
#
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:~/.bin:~/.local/bin

HISTCONTROL=ignoreboth;
HISTIGNORE=l:ll:h:rmj:lm:llm:ls:lsa:lsd:ltr:d:m
HISTSIZE=-1
HISTFILESIZE=-1
HISTTIMEFORMAT='%F %T ';
shopt -s no_empty_cmd_completion

export EDITOR='emacs -nw'

#
# functions
#


#
# emacs
#
function e() {
    if [ "$TERM" = 'linux' ]; then
        (emacs "$1");
    elif [ -n ${xterm#$TERM} ]; then
        for file in "$@"; do
            (emacs "$file" &);
        done
    fi
}

#
# prompt to descend
#
function prompt {
    msg="$1";

    read -p "$msg? [Y/n]"

    if [ -z "$REPLY" -o "$REPLY" == "y" -o "$REPLY" == "Y" ]; then
	return 0;
    else
	return 1;
    fi
}

#
# removes emacs backup files
#
function rmj() {
    startdir="${1:-.}";

    if [ ! -d "$startdir" ]; then
	echo "Non-existant dir";
	return 0;
    fi

    if [ -f "$startdir/.normj" ]; then
	echo "Found .normj. Exiting.";
	return 0;
    fi

    findcmd='find "$startdir" \( -name \*~ -o -name .\*~ -o -name \#*\#  -o -name .\#* -o -name \*.pyc \)';

    retval=$(eval "$findcmd");
    if [ -z "$retval" ]; then
	echo "${1:-$(pwd)}/* is clean";
	return 0;
    else
	echo "$retval";
    fi

    if ! prompt "Descend and delete"; then
	return 0;
    fi

    findcmd="$findcmd -exec rm {} \;";
    eval "$findcmd";

    eval 'find . -type d -empty -name __pycache__ -delete';
}

#
# git branch
#
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(* \1)/'
}

function xfill {
    TERMWIDTH=${COLUMNS}
    promptsize=$(echo -n "{yyyy-mm-dd HH:MM:ss}[$(pwd)] " | wc -c | tr -d " ")

    branchsize=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(* \1)/' | wc -c);

    padding=8;
    venv_padding=$(basename "$VIRTUAL_ENV" | wc -c)
    fillsize=$((TERMWIDTH-promptsize-branchsize-padding-venv_padding))
    fill=""
    while [ "$fillsize" -gt "0" ]; do
	fill="${fill}_"
	fillsize=$((fillsize-1))
    done
    echo -n $fill
}



#
# ergo prompt
#
function ep() {
    set +v

    # color codes
    clr_green="\[\033[32m\]";
    clr_white="\[\033[0m\]";
    clr_blue="\[\033[34m\]";
    clr_lightblue="\[\033[1;34m\]";
    clr_red="\[\033[31m\]";
    clr_lightgray="\[\033[0;37m\]";
    clr_darkgray="\[\033[1;30m\]";
    clr_brown="\[\033[0;33m\]";
    clr_magenta="\[\033[0;35m\]";

    # ergo prompt variables / colors
    clr_path=$clr_green;
    clr_bg=$clr_white;
    clr_host=$clr_red;
    clr_bar=$clr_lightgray;
    clr_branch=$clr_magenta;
    clr_user=$clr_lightblue;
    clr_dir=$clr_lightblue;

    #
    # ergo xterm prompt (black text on white background)
    #
    if [[ -n "${xterm#$TERM}" ]]; then
	clr_user=$clr_blue;
	clr_dir=$clr_blue;
    fi

    #
    # ergo linux prompt (white text on black background)
    #
    if [ "$TERM" == 'linux' ]; then
	clr_user=$clr_lightblue;
	clr_dir=$clr_lightblue;
    fi

    PS1="$clr_bar{\D{%Y-%m-%d} \t}$clr_bg$clr_path[\$(pwd)]$clr_bg \$(xfill)$clr_branch\$(parse_git_branch)$clr_bg\n$clr_user\u$clr_bg@$clr_host\h$clr_bg$clr_dir \W $clr_bg\$ "

} # end ergo prompt

#
# use the ergo prompt
#
ep;


#
# aliases
#

#
# aliases
#
alias man='man -P "less -F -X"'
alias mm='less -F -X -e';

alias als='ls --color=always'; # to temporarily disable, use: unalias ls or pls
alias pls='ls --color=never '; # do not use colors

alias l='als -lF ';
alias lh='als -lh ';
alias ll='als -lAF ';
alias lm='l | m ';
alias llm='ll | m '
alias lsd='als -lAd */ '; # list only directories
alias ltr='l -tr'; # list in reverse order of creation/modified time
alias lltr='als -lAFtr'; # list in reverse order of creation/modified time
alias g='grep ';
alias md='mkdir ';

alias ..='cd ..;pwd ';
alias ...='cd ../..;pwd ';
alias ....='cd ../../..;pwd ';
alias .....='cd ../../../..;pwd ';
alias rm='rm -i ';

alias acs='apt-cache search ';
alias acw='apt-cache show ';
alias cdd='cd ~/downloads ';
alias ack='ack --color-lineno=magenta --color-filename=blue ';
alias en='emacs -nw';
