#alias ndocker="nvm use '$(grep -oE 'FROM node:([0-9]+)' Dockerfile | sed 's/FROM node://')'"

arturlog() {
    local color=""

    case "$2" in
        "ERROR")
            color="\033[1;31m"  # red
            ;;
        "WARN")
            color="\033[1;33m"  # yellow
            ;;
        *)
            color=""
            ;;
    esac

    if [ -z "$color" ]; then
        echo "$1"
    else
        echo -e "${color}$1\033[0m"  # Reset color
    fi
}

nvmdocker() {
    if [ -f Dockerfile ]; then
        local dockerfile_node_version=$(grep -oE 'FROM node:([0-9]+)' Dockerfile | sed 's/FROM node://')
        if [ -n "$dockerfile_node_version" ];
        then
            fnm use "$dockerfile_node_version"
	else
		arturlog "Failed to establish required Node version - 'fnm use XX' command skipped" WARN
        fi
    else
	arturlog "Dockerfile missing - 'fnm use XX' command skipped" WARN	
    fi
}

repo() {
    if [ "$1" != "" ]; then
        if cd ~/REPOS/$1; then
            set_tab $1
            nvmdocker
	else
		arturlog "Repository doesn't exist." ERROR
        fi
    else
        arturlog "Repository name is missing (1)." ERROR
    fi
    if [ "$2" != "" ]; then
	npm run $2
    fi
}

