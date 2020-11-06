function cdd() {
    cd "$1"
    ls
}

#do a ps aux and then grep for a process name, keeping the column names
#args: process name
psaux(){
    ps aux | sed -n "1p; /"$1"/p;"
}

alias show-me-the-money="git log  --graph --pretty=format:'%h -%d% %s (%ci - %cr) <%an>' --abbrev-commit | vi -R -c 'set filetype=git' -"

function overwrite-branch() {
    git push origin $(git symbolic-ref --short HEAD):$1 --force
}

HISTSIZE=10000000
SAVEHIST=10000000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
#setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

# some tmux stuff
export TERM="screen-256color"
alias tmux="tmux -2"

## word manipulation
# set word characters so e.g. ctrl+w works like bash (back to space)
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'

# set custom behavior for alt+delete bash-style to slash
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir
