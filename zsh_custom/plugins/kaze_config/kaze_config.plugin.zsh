# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.

### shell / terminal conveniences

# cd + ls in one command
function cdd() {
    cd "$1"
    ls
}

# do a ps aux and then search for a process name (case insensitive), keeping the column names
# brew install gnu-sed if you don't have gsed already
psaux(){
    ps aux | gsed -n "1p; /"$1"/Ip;"
}


### git shortcuts

# show git commit history in vim more where you can hit "shift + k" on the commit hash to see the contents
alias show-me-the-money="git log  --graph --pretty=format:'%h -%d% %s (%ci - %cr) <%an>' --abbrev-commit | vi -R -c 'set filetype=git' -"

# force push your branch to a remote branch
function overwrite-branch() {
    git push origin $(git symbolic-ref --short HEAD):$1 --force
}


### shell history configuration

HISTSIZE=10000000
SAVEHIST=10000000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
#setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
export HISTORY_IGNORE='(exit)'


### tmux configuration

export TERM="screen-256color"
alias tmux="tmux -2"


### terminal word manipulation

# set word characters so e.g. ctrl+w works like bash (back to space)
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>:"@'\'''

# set custom behavior for alt+delete bash-style to delete back to slash/dot/dash/underscore
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    local WORDCHARS=${WORDCHARS/\.}
    local WORDCHARS=${WORDCHARS//\_\-}
    local WORDCHARS=${WORDCHARS//\*}
    zle backward-kill-word
}
# bind to alt+backspace
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

# ctrl+u delete from cursor to front of line
bindkey \^U backward-kill-line
