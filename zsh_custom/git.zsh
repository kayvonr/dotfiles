alias show-me-the-money="git log  --graph --pretty=format:'%h -%d% %s (%ci - %cr) <%an>' --abbrev-commit | vi -R -c 'set filetype=git' -"

function overwrite-branch() {
    git push origin $(git symbolic-ref --short HEAD):$1 --force
}
