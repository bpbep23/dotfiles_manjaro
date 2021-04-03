export EDITOR=/usr/bin/nvim
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
export XDG_BIN_HOME=$HOME/.local/bin

export LESS_TERMCAP_md="${yellow}";
export GOPATH=$HOME/code/go
export GOBIN=$GOPATH/bin
export BROWSER=/usr/bin/firefox
export BASHDOTDPATH=$HOME/bash.d

export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --multi --bind 'ctrl-a:select-all' --bind  'ctrl-a:+accept'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'exa -a -C {} | head -200'"

export GHCUP_USE_XDG_DIRS=1

LESS='-Rf';export LESS

source "$HOME/.cargo/env"

PATH=$PATH:$HOME/.gem/ruby/2.7.0/bin/
PATH=$PATH:$HOME/node_modules/.bin/
PATH=$PATH:$GOBIN
PATH=$PATH:$BASHDOTDPATH/bin/
PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

export PATH
