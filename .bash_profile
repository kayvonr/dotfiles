# git repo in prompt
source ~/.git-completion.bash
source ~/.git-completion-full.bash
PS1='\W$(__git_ps1 " (%s)") \$ '

# some data sources
if [ -f ~/.data_sources ]; then
    source ~/.data_sources
fi

# bash completion (?)
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

#do a ps aux and then grep for a process name, keeping the column names
#args: process name
psaux(){
    ps aux | sed -n "1p; /"$1"/p;"
}

# locate by exact filename
flocate() {
  if [ $# -gt 1 ] ; then
    display_divider=1
  else
    display_divider=0
  fi

  current_argument=0
  total_arguments=$#
  while [ ${current_argument} -lt ${total_arguments} ] ; do
    current_file=$1
    if [ "${display_divider}" = "1" ] ; then
      echo "----------------------------------------"
      echo "Matches for ${current_file}"
      echo "----------------------------------------"
    fi

    filename_re="^\(.*/\)*$( echo ${current_file} | sed s%\\.%\\\\.%g )$"
    locate -r "${filename_re}"
    shift
    (( current_argument = current_argument + 1 ))
  done
}

#function to do a cd and ls in one command
cdd() {
    cd "$1"
    ls 
}

delete_ssh_entry() {
    sed -i -e ${1}d ~/.ssh/known_hosts 
}


#don't log back-to-back duplicate commands in bash history
export HISTCONTROL=ignoredups
# really long history
export HISTSIZE=500000
export HISTFILESIZE=5000000

# colored ls
export CLICOLOR=1
#export LSCOLORS=Exfxcxdxbxegedabagacad
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

#For cscope, so it uses correct version of vim
export EDITOR=vim

alias vi=vim
alias emacs=vim

# non-mac python setup
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# some tmux stuff
export TERM="screen-256color"
alias tmux="tmux -2"

# git history into vim for man-page commit content
alias show-me-the-money="git log  --graph --pretty=format:'%h -%d% %s (%ci - %cr) <%an>' --abbrev-commit | vi -R -c 'set filetype=git' -"
overwrite-branch() {
    git push origin $(git symbolic-ref --short HEAD):$1 --force
}
# as of OS X catalina apple shows a deprecation warning for bash
export BASH_SILENCE_DEPRECATION_WARNING=1
