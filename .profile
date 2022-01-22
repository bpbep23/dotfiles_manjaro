export EDITOR=/usr/bin/nvim
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
export XDG_BIN_HOME=$HOME/.local/bin

export LESS_TERMCAP_md="${yellow}"
export GOPATH=$HOME/code/go
export GOBIN=$GOPATH/bin
export BROWSER=/usr/bin/firefox
export BASHDOTDPATH=$HOME/bash.d

export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --multi --bind 'ctrl-a:select-all' --bind  'ctrl-a:+accept'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'exa -a -C {} | head -200'"

export GHCUP_USE_XDG_DIRS=1

export SDCV_PAGER='bat --plain --language=html --paging=always'

export ANSIWEATHERRC=$XDG_CONFIG_HOME/ansiweather/.ansiweatherrc

LESS='-Rf'
export LESS

# export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
export NNN_COLORS="2136"                           # use a different color for each context
export NNN_TRASH=1                                 # trash (needs trash-cli) instead of delete
export NNN_BMS='d:~/Documents;c:~/code;h:/home/bpb;l:~/code/lab;C:~/code/clones;p:~/Pictures;D:~/Downloads;b:~/Documents/books;m:~/Music;u:~/.config'
export NNN_PLUGS='preview_tui_ext:p;preview_tui:P'
export NNN_FIFO='~/.config/nnn/nnn_fifo'

export INFOPATH=$HOME/.local/share/info:/usr/share/info:/usr/local/share/info

export DIFFPROG='nvim -d'

export DOTNET_CLI_TELEMETRY_OPTOUT=1

source "$HOME/.cargo/env"

PATH=$PATH:$HOME/.gem/ruby/2.7.0/bin/
PATH=$PATH:$HOME/node_modules/.bin/
PATH=$PATH:$GOBIN
PATH=$PATH:$BASHDOTDPATH/bin/
PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"
PATH=$PATH:$HOME/.dotj

export NVIM_TUI_ENABLE_TRUE_COLOR=1

export PATH
