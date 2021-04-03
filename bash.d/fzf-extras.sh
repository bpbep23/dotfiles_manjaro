#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# directory
# -----------------------------------------------------------------------------

# fzf --preview command for file and directory
if type bat >/dev/null 2>&1; then
    FZF_PREVIEW_CMD='bat --color=always --plain --line-range :$FZF_PREVIEW_LINES {}'
elif type pygmentize >/dev/null 2>&1; then
    FZF_PREVIEW_CMD='head -n $FZF_PREVIEW_LINES {} | pygmentize -g'
else
    FZF_PREVIEW_CMD='head -n $FZF_PREVIEW_LINES {}'
fi

# zdd - cd to selected directory
zdd() {
    local dir
    dir="$(
        find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null |
            fzf +m \
                --preview='tree -C {} | head -n $FZF_PREVIEW_LINES' \
                --preview-window='right:hidden:wrap' \
                --bind=ctrl-v:toggle-preview \
                --bind=ctrl-x:toggle-sort \
                --header='(view:ctrl-v) (sort:ctrl-x)'
    )" || return
    cd "$dir" || return
}

# zda - including hidden directories
zda() {
    local dir
    dir="$(
        find "${1:-.}" -type d 2>/dev/null |
            fzf +m \
                --preview='tree -C {} | head -n $FZF_PREVIEW_LINES' \
                --preview-window='right:hidden:wrap' \
                --bind=ctrl-v:toggle-preview \
                --bind=ctrl-x:toggle-sort \
                --header='(view:ctrl-v) (sort:ctrl-x)'
    )" || return
    cd "$dir" || return
}

# zdr - cd to selected parent directory
zdr() {
    local dirs=()
    local parent_dir

    get_parent_dirs() {
        if [[ -d "$1" ]]; then dirs+=("$1"); else return; fi
        if [[ "$1" == '/' ]]; then
            for _dir in "${dirs[@]}"; do echo "$_dir"; done
        else
            get_parent_dirs "$(dirname "$1")"
        fi
    }

    parent_dir="$(
        get_parent_dirs "$(realpath "${1:-$PWD}")" |
            fzf +m \
                --preview 'tree -C {} | head -n $FZF_PREVIEW_LINES' \
                --preview-window='right:hidden:wrap' \
                --bind=ctrl-v:toggle-preview \
                --bind=ctrl-x:toggle-sort \
                --header='(view:ctrl-v) (sort:ctrl-x)'
    )" || return

    cd "$parent_dir" || return
}

# zst - cd into the directory from stack
zst() {
    local dir
    dir="$(
        dirs |
            sed 's#\s#\n#g' |
            uniq |
            sed "s#^~#$HOME#" |
            fzf +s +m -1 -q "$*" \
                --preview='tree -C {} | head -n $FZF_PREVIEW_LINES' \
                --preview-window='right:hidden:wrap' \
                --bind=ctrl-v:toggle-preview \
                --bind=ctrl-x:toggle-sort \
                --header='(view:ctrl-v) (sort:ctrl-x)'
    )"
    # check $dir exists for Ctrl-C interrupt
    # or change directory to $HOME (= no value cd)
    if [[ -d "$dir" ]]; then
        cd "$dir" || return
    fi
}

# zdf - cd into the directory of the selected file
zdf() {
    local file
    file="$(
        fzf +m -q "$*" \
            --preview="${FZF_PREVIEW_CMD}" \
            --preview-window='right:hidden:wrap' \
            --bind=ctrl-v:toggle-preview \
            --bind=ctrl-x:toggle-sort \
            --header='(view:ctrl-v) (sort:ctrl-x)'
    )"
    cd "$(dirname "$file")" || return
}

# zz - selectable cd to frecency directory
zz() {
    local dir

    dir="$(
        fasd -dl |
            fzf \
                --tac \
                --reverse \
                --select-1 \
                --no-sort \
                --no-multi \
                --tiebreak=index \
                --bind=ctrl-x:toggle-sort \
                --query "$*" \
                --preview='tree -C {} | head -n $FZF_PREVIEW_LINES' \
                --preview-window='right:hidden:wrap' \
                --bind=ctrl-v:toggle-preview \
                --bind=ctrl-x:toggle-sort \
                --header='(view:ctrl-v) (sort:ctrl-x)'
    )" || return

    cd "$dir" || return
}

# zd - cd into selected directory with options
# The super function of zdd, zda, zdr, zst, zdf, zz
zd() {
    read -r -d '' helptext <<EOF
usage: zd [OPTIONS]
  zd: cd to selected options below
OPTIONS:
  -d [path]: Directory (default)
  -a [path]: Directory included hidden
  -r [path]: Parent directory
  -s [query]: Directory from stack
  -f [query]: Directory of the selected file
  -z [query]: Frecency directory
  -h: Print this usage
EOF

    usage() {
        echo "$helptext"
    }

    if [[ -z "$1" ]]; then
        # no arg
        zdd
    elif [[ "$1" == '..' ]]; then
        # arg is '..'
        shift
        zdr "$1"
    elif [[ "$1" == '-' ]]; then
        # arg is '-'
        shift
        zst "$*"
    elif [[ "${1:0:1}" != '-' ]]; then
        # first string is not -
        zdd "$(realpath "$1")"
    else
        # args is start from '-'
        while getopts darfszh OPT; do
            case "$OPT" in
            d)
                shift
                zdd "$1"
                ;;
            a)
                shift
                zda "$1"
                ;;
            r)
                shift
                zdr "$1"
                ;;
            s)
                shift
                zst "$*"
                ;;
            f)
                shift
                zdf "$*"
                ;;
            z)
                shift
                zz "$*"
                ;;
            h)
                usage
                return 0
                ;;
            *)
                usage
                return 1
                ;;
            esac
        done
    fi
}

# -----------------------------------------------------------------------------
# file
# -----------------------------------------------------------------------------

# e - open 'frecency' files in $VISUAL editor
fzerecent() {
    local IFS=$'\n'
    local files=()

    files=(
        "$(
            fasd -fl |
                fzf \
                    --tac \
                    --reverse -1 \
                    --no-sort \
                    --multi \
                    --tiebreak=index \
                    --bind=ctrl-x:toggle-sort \
                    --query "$*" \
                    --preview="${FZF_PREVIEW_CMD}" \
                    --preview-window='right:hidden:wrap' \
                    --bind=ctrl-v:toggle-preview \
                    --bind=ctrl-x:toggle-sort \
                    --header='(view:ctrl-v) (sort:ctrl-x)'
        )"
    ) || return

    "${EDITOR:-nvim}" "${files[@]}"
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fzedit() {
    local IFS=$'\n'
    local files=()
    files=(
        "$(
            fzf-tmux \
                --query="$1" \
                --multi \
                --select-1 \
                --exit-0 \
                --preview="${FZF_PREVIEW_CMD}" \
                --preview-window='right:hidden:wrap' \
                --bind=ctrl-v:toggle-preview \
                --bind=ctrl-x:toggle-sort \
                --header='(view:ctrl-v) (sort:ctrl-x)'
        )"
    ) || return
    "${EDITOR:-nvim}" "${files[@]}"
}

# fo - Modified version of fe() where you can press
#   - CTRL-O to open with $OPENER,
#   - CTRL-E or Enter key to open with $EDITOR
fzopen() {
    local IFS=$'\n'
    local out=()
    local key
    local file

    out=(
        "$(
            fzf-tmux \
                --query="$1" \
                --exit-0 \
                --expect=ctrl-o,ctrl-e
        )"
    )
    key="$(head -1 <<<"${out[@]}")"
    file="$(head -2 <<<"${out[@]}" | tail -1)" || return

    if [[ "$key" == ctrl-o ]]; then
        "${OPENER:-xdg-open}" "$file"
    else
        "${EDITOR:-nvim}" "$file"
    fi
}

# # v - open files in ~/.nviminfo
# v() {
#   local files
#   files="$(
#     grep '^>' "$HOME/.nviminfo" \
#       | cut -c3- \
#       | while read -r line; do
#           [[ -f "${line/\~/$HOME}" ]] && echo "$line"
#         done \
#       | fzf -m -0 -1 -q "$*"
#   )"
#   "${EDITOR:-nvim}" "${files/\~/$HOME}"
# }

# -----------------------------------------------------------------------------
# git
# -----------------------------------------------------------------------------

# fbr - checkout git branch (including remote branches)
#   - sorted by most recent commit
#   - limit 30 last branches
fbr() {
    local branches
    local num_branches
    local branch
    local target

    branches="$(
        git for-each-ref \
            --count=30 \
            --sort=-committerdate \
            refs/heads/ \
            --format='%(refname:short)'
    )" || return

    num_branches="$(wc -l <<<"$branches")"

    branch="$(
        echo "$branches" |
            fzf-tmux -d "$((2 + "$num_branches"))" +m
    )" || return

    target="$(
        echo "$branch" |
            sed "s/.* //" |
            sed "s#remotes/[^/]*/##"
    )" || return

    git checkout "$target"
}

# fco - checkout git branch/tag
fco() {
    local tags
    local branches
    local target

    tags="$(
        git tag |
            awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'
    )" || return

    branches="$(
        git branch --all |
            grep -v HEAD |
            sed 's/.* //' |
            sed 's#remotes/[^/]*/##' |
            sort -u |
            awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}'
    )" || return

    target="$(
        printf '%s\n%s' "$tags" "$branches" |
            fzf-tmux \
                -l40 \
                -- \
                --no-hscroll \
                --ansi \
                +m \
                -d '\t' \
                -n 2 \
                -1 \
                -q "$*"
    )" || return

    git checkout "$(echo "$target" | awk '{print $2}')"
}

# fcoc - checkout git commit
fcoc() {
    local commits
    local commit

    commits="$(
        git log --pretty=oneline --abbrev-commit --reverse
    )" || return

    commit="$(
        echo "$commits" |
            fzf --tac +s +m -e
    )" || return

    git checkout "$(echo "$commit" | sed "s/ .*//")"
}

# fcs - get git commit sha
# example usage: git rebase -i "$(fcs)"
fcs() {
    local commits
    local commit

    commits="$(
        git log \
            --color=always \
            --pretty=oneline \
            --abbrev-commit \
            --reverse
    )" || return

    commit="$(
        echo "$commits" |
            fzf \
                --tac \
                +s \
                +m \
                -e \
                --ansi \
                --reverse
    )" || return

    echo -n "$(echo "$commit" | sed "s/ .*//")"
}

# fshow - git commit browser
fshow() {
    local execute

    execute="grep -o \"[a-f0-9]\{7\}\" \
        | head -1 \
        | xargs -I % sh -c 'git show --color=always %'"

    git log \
        --graph \
        --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf \
            --ansi \
            --no-sort \
            --reverse \
            --tiebreak=index \
            --bind=ctrl-s:toggle-sort \
            --bind "ctrl-m:execute: ($execute) <<'FZF-EOF'
            {}
            FZF-EOF"
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fstash() {
    local out
    local q
    local k
    local sha

    while out="$(
        git stash list --pretty='%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs' |
            fzf \
                --ansi \
                --no-sort \
                --query="$q" \
                --print-query \
                --expect=ctrl-d,ctrl-b
    )"; do
        mapfile -t out <<<"$out"
        q="${out[0]}"
        k="${out[1]}"
        sha="${out[-1]}"
        sha="${sha%% *}"
        [[ -z "$sha" ]] && continue
        if [[ "$k" == 'ctrl-d' ]]; then
            git diff "$sha"
        elif [[ "$k" == 'ctrl-b' ]]; then
            git stash branch "stash-$sha" "$sha"
            break
        else
            git stash show -p "$sha"
        fi
    done
}

# fzf-gitlog-widget - git log browser
fzf-gitlog-widget() {
    local git_cmd
    local execute
    local fzf_cmd

    # %s: comment
    # %d: branch/tag
    # %h: hash
    # %cd: date
    # %an: author
    git_cmd='git log \
      --all \
      --graph \
      --date-order \
      --format=format:"%C(auto)%s %d %h %C(cyan)%cd %C(bold black)%an %C(auto)" \
      --date=short \
      --color=always'

    execute="grep -o '[a-f0-9]\{7\}' \
      | head -1 \
      | xargs -I % sh -c 'git show --color=always % | less -R'"

    fzf_cmd='fzf \
      --height=100% \
      --ansi \
      --reverse \
      --no-sort \
      --tiebreak=index \
      --bind=ctrl-x:toggle-sort'
    fzf_cmd="$fzf_cmd --bind \"ctrl-m:execute: ($execute) <<'FZF-EOF'
        {}
        FZF-EOF\""

    eval "$git_cmd | $fzf_cmd"
}

# fzf-gitlog-multi-widget - multi-selectable git show
#
# 1. Show `git log --graph`
# 2. Fuzzy Search
# 3. Select Tab key
# 4. Enter, then push selected commit message into STDOUT
#
# You can use pipe like below
# ```
# # Show only date
# fzf-gitlog-multi-widget | grep date
# # Commit message highlight 'hoge'
# fzf-gitlog-multi-widget | less -P 'hoge'
# ```
#
fzf-gitlog-multi-widget() {
    local git_cmd
    local fzf_cmd

    git_cmd='git log \
    --all \
    --graph \
    --date-order \
    --format=format:"%C(auto)%s %d %h %C(cyan)%cd %C(bold black)%an %C(auto)" \
    --date=short \
    --color=always'

    fzf_cmd='fzf \
    --height 100% \
    --multi \
    --ansi \
    --reverse \
    --no-sort \
    --tiebreak=index \
    --bind=ctrl-x:toggle-sort'

    eval "$git_cmd | $fzf_cmd" |
        grep -o '[a-f0-9]\{7\}' |
        xargs -I % sh -c 'git show % --color' |
        cat
}

# -----------------------------------------------------------------------------
# history
# -----------------------------------------------------------------------------

# runcmd - utility function used to run the command in the shell
runcmd() {
    perl -e 'ioctl STDOUT, 0x5412, $_ for split //, <>'
}

# fh - repeat history
fh() {
    ([[ -n "$ZSH_NAME" ]] && fc -l 1 || history) |
        fzf +s --tac |
        sed -re 's/^\s*[0-9]+\s*//' |
        runcmd
}

# writecmd - utility function used to write the command in the shell
writecmd() {
    perl -e 'ioctl STDOUT, 0x5412, $_ for split //, do { chomp($_ = <>); $_ }'
}

# fhe - repeat history edit
fhe() {
    ([[ -n "$ZSH_NAME" ]] && fc -l 1 || history) |
        fzf +s --tac |
        sed -re 's/^\s*[0-9]+\s*//' |
        writecmd
}

# -----------------------------------------------------------------------------
# pid
# -----------------------------------------------------------------------------

# fkill - kill process
fzkill() {
    local pid

    pid="$(
        ps -ef |
            sed 1d |
            fzf -m |
            awk '{print $2}'
    )" || return

    kill -"${1:-9}" "$pid"
}

# -----------------------------------------------------------------------------
# tags
# -----------------------------------------------------------------------------

# ftags - search ctags
fztags() {
    local line

    [[ -e 'tags' ]] || return

    line="$(
        awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
            cut -c1-"$COLUMNS" |
            fzf --nth=2 --tiebreak=begin
    )" || return

    "${EDITOR:-nvim}" "$(cut -f3 <<<"$line")" \
        -c 'set nocst' \
        -c "silent tag \"$(cut -f2 <<<"$line")\""
}

# -----------------------------------------------------------------------------
# tmux
# -----------------------------------------------------------------------------

fztsesh() {
    [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
    if [ "$1" ]; then
        tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s "$1" && tmux $change -t "$1")
        return
    fi
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) && tmux $change -t "$session" || echo "No sessions found."
}

# ftpane - switch pane (@george-b)
fztpane() {
    local panes
    local current_window
    local current_pane
    local target
    local target_window
    local target_pane

    panes="$(
        tmux list-panes \
            -s \
            -F '#I:#P - #{pane_current_path} #{pane_current_command}'
    )"
    current_pane="$(tmux display-message -p '#I:#P')"
    current_window="$(tmux display-message -p '#I')"

    target="$(
        echo "$panes" |
            grep -v "$current_pane" |
            fzf +m --reverse
    )" || return

    target_window="$(
        echo "$target" |
            awk 'BEGIN{FS=":|-"} {print$1}'
    )"

    target_pane="$(
        echo "$target" |
            awk 'BEGIN{FS=":|-"} {print$2}' |
            cut -c 1
    )"

    if [[ "$current_window" -eq "$target_window" ]]; then
        tmux select-pane -t "$target_window.$target_pane"
    else
        tmux select-pane -t "$target_window.$target_pane" &&
            tmux select-window -t "$target_window"
    fi
}

fzrgp() {
    if [ ! "$#" -gt 0 ]; then
        echo "Need a string to search for!"
        return 1
    fi
    rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# Same as above, but with previews and works correctly with man pages in
# different sections.  Quickly display a man page using fzf and fd. MANPATH has
# to be set to a single directory (usually /usr/share/man). Accepts an optional
# argument for the manual section (defaults to 1).
fzman() {
    man -k . | fzf -q "$1" --prompt='man> ' --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}

fzrga() {
    RG_PREFIX="rga --files-with-matches"
    local file
    file="$(
        FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
            fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
            --phony -q "$1" \
            --bind "change:reload:$RG_PREFIX {q}" \
            --preview-window="70%:wrap"
    )" &&
        echo "opening $file" &&
        xdg-open "$file"
}

fzpdf() {
    open=xdg-open # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.

    ag -U -g ".pdf$" |
        fast-p |
        fzf --read0 --reverse -e -d $'\t' \
            --preview-window down:80% --preview '
                            v=$(echo {q} | tr " " "|"); 
                            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
                            ' |
        cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open >/dev/null 2>/dev/null
}

# vim: ft=sh:
