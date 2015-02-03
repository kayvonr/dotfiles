# git repo in prompt
source ~/.git-completion-full.bash
PS1='[\H \W$(__git_ps1 " (%s)")]\$ '

# some data sources
source ~/.data_sources

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


#don't log back-to-back duplicate commands in bash history
export HISTCONTROL=ignoredups
# really long history
export HISTSIZE=100000
export HISTFILESIZE=100000

# colored ls
export CLICOLOR=1
#export LSCOLORS=Exfxcxdxbxegedabagacad
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

#For cscope, so it uses correct version of vim
export EDITOR=vim

alias vi=vim
alias emacs=vim

# To find ack (mainly)
export PATH=~/bin:$PATH

# Find yh-python modules
#export PYTHONPATH=/Users/kraphael/src/link:$PYTHONPATH
export PYTHONPATH=/Users/kraphael/src/yh-python:$PYTHONPATH
export PYTHONPATH=/Users/kraphael/src/python_scripts:$PYTHONPATH

# added by Anaconda 2.0.1 installer
export PATH="/Users/kraphael/anaconda/bin:$PATH"


# GAH BREW AND ITS PERMISSIONS
alias htop="/usr/local/Cellar/htop-osx/0.8.2.2/bin/htop"


# woohoo java development
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_20.jdk/Contents/Home/jre/

# le scalas
export SCALA_HOME=/usr/local/share/scala
export PATH=$PATH:$SCALA_HOME/bin

# get to the amazon shit
alias go_aws="ssh -i ~/Documents/yh_docs/creds/amazon_prod.pem "

# some tmux stuff
export TERM="screen-256color"
alias tmux="tmux -2"
