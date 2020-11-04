function cdd() {
    cd "$1"
    ls
}

#do a ps aux and then grep for a process name, keeping the column names
#args: process name
psaux(){
    ps aux | sed -n "1p; /"$1"/p;"
}
