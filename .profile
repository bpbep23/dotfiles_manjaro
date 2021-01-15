export EDITOR=/usr/bin/nvim
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export LESS_TERMCAP_md="${yellow}";
export GOPATH=$HOME/code/go
export GOBIN=$GOPATH/bin

source "$HOME/.cargo/env"

PATH=$PATH:$HOME/.gem/ruby/2.7.0/bin/
PATH=$PATH:$HOME/node_modules/.bin/
PATH=$PATH:$GOBIN

export PATH
