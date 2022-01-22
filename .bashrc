#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
  local fgc bgc vals seq0

  printf "Color escapes are \e[${value};...;${value}m\n"
  printf "Values 30..37 are \e[33mforeground colors\e[m\n"
  printf "Values 40..47 are \e[43mbackground colors\e[m\n"
  printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

  # foreground colors
  for fgc in {30..37}; do
    # background colors
    for bgc in {40..47}; do
      fgc=${fgc#37} # white
      bgc=${bgc#40} # black

      vals="${fgc:+$fgc;}${bgc}"
      vals=${vals%%;}

      seq0="${vals:+\e[${vals}m}"
      printf "  %-9s" "${seq0:-(default)}"
      printf " ${seq0}TEXT\e[m"
      printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
    done
    echo
    echo
  done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
xterm* | rxvt* | Eterm* | aterm | kterm | gnome* | interix | konsole*)
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
  ;;
screen*)
  PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
  ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?} # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] &&
  type -P dircolors >/dev/null &&
  match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color}; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  if type -P dircolors >/dev/null; then
    if [[ -f ~/.dir_colors ]]; then
      eval "$(dircolors -b ~/.dir_colors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
      eval "$(dircolors -b /etc/DIR_COLORS)"
    fi
  fi

  if [[ ${EUID} == 0 ]]; then
    PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
  else
    PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
  fi

  alias ls='ls --color=auto'
  alias grep='grep --colour=auto'
  alias egrep='egrep --colour=auto'
  alias fgrep='fgrep --colour=auto'
else
  if [[ ${EUID} == 0 ]]; then
    # show root@ when we don't have colors
    PS1='\u@\h \W \$ '
  else
    PS1='\u@\h \w \$ '
  fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"     # confirm before overwriting something
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

xhost +local:root >/dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex() {
  if [ -f "$1" ]; then
    case $1 in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

shopt -s nocaseglob
shopt -s globstar

source "$HOME/.cargo/env"

# NOTE: I handle all system wide env var manipulations and exports in .profile
# PATH="$PATH":$HOME/.gem/ruby/2.7.0/bin/
# export PATH

[[ -r /usr/share/fzf/key-bindings.bash ]] && . /usr/share/fzf/key-bindings.bash
[[ -r /usr/share/fzf/completion.bash ]] && . /usr/share/fzf/completion.bash

bind "$(bind -s | grep '^"\\C-r"' | sed 's/"/"\\C-x/' | sed 's/"$/\\C-m"/')"

[[ -e "$BASHDOTDPATH/fzf-extras.sh" ]] && source "$BASHDOTDPATH/fzf-extras.sh"

if [[ -e "$BASHDOTDPATH/completions/" ]]; then
  for f in "$BASHDOTDPATH"/completions/*; do
    . "$f"
  done
fi

eval "$(zoxide init bash)"

for f in "$HOME"/bash.d/*; do
  [[ ! -d $f ]] && . "$f"
done

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/bpb/code/anaconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/home/bpb/code/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/home/bpb/code/anaconda3/etc/profile.d/conda.sh"
  else
    export PATH="/home/bpb/code/anaconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

if [ -f "/home/bpb/bash.d/bash_prompt" ]; then
  . "/home/bpb/bash.d/bash_prompt"
fi

PATH="/home/bpb/perl5/bin${PATH:+:${PATH}}"
export PATH
PERL5LIB="/home/bpb/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL5LIB
PERL_LOCAL_LIB_ROOT="/home/bpb/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_LOCAL_LIB_ROOT
PERL_MB_OPT="--install_base \"/home/bpb/perl5\""
export PERL_MB_OPT
PERL_MM_OPT="INSTALL_BASE=/home/bpb/perl5"
export PERL_MM_OPT

[ -f "/home/bpb/.ghcup/env" ] && source "/home/bpb/.ghcup/env" # ghcup-env
eval "$(stack --bash-completion-script stack)"

# man prompt hacking
export MANPAGER='less +Gg -Rf'
export PROMPT_COMMAND=mannyprompt
mannyprompt() {
  # set line width for man pages with maximum of 80
  if [ $COLUMNS -lt 125 ]; then
    export MANWIDTH=$COLUMNS
  else
    export MANWIDTH=125
  fi
}
# manpage coloring
export MANROFFOPT='-c'
# export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
# export LESS_TERMCAP_md=$(tput bold; tput setaf 6)
# export LESS_TERMCAP_me=$(tput sgr0)
# export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
# export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
# export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
# export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
# export LESS_TERMCAP_mr=$(tput rev)
# export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)

source "$HOME/bash.d/bin/fzf-marks"
