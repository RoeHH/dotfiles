# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

export PATH=$PATH:~/kafka/confluent-7.2.1/bin:/home/hr7/tools/idea-IU-232.9921.47/bin

# >>> Deno >>>
export DENO_INSTALL="/home/$USER/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
deno upgrade &> /dev/null

# >>> Roe's Commands :) >>>
alias cdg="cd ~/git/rigi";
alias ..="cd ..";

reset(){
    git fetch origin
    git reset --hard origin/master
    npm ci
    npm run build
    npm run start
}

pull(){
    if [ "$#" -ne 1 ]; then
        echo "Usage: pull <directory>"
    else
        DIRECTORY=$1
        if [ ! -d "$DIRECTORY" ]; then
            echo "Error: Directory $DIRECTORY does not exist."
        else
            CURRENT_DIR=$(pwd)
            cd "$DIRECTORY"
            if [ ! -d ".git" ]; then
                echo "Error: $DIRECTORY is not a Git repository."
                cd "$CURRENT_DIR"
            else
                AHEAD_COUNT=$(git rev-list --count origin..HEAD)
                if [ "$AHEAD_COUNT" -ne 0 ]; then
                    echo "Error: The repository has changes that are ahead of the origin."
                    cd "$CURRENT_DIR"
                else
                    git pull
                    cd "$CURRENT_DIR"
                fi
            fi
        fi
    fi
} 

killport(){
    sudo kill -9 $(sudo lsof -t -i:$1)
}

alias kill-p="killport";
alias kill-port="killport";

ct(){
    output_file="diff.txt"

    find . -type d -name i18n | while read dir; do
    files=($(find "$dir" -name "*.json" ! -path "*/node_modules/*" ! -path "*/dist/*" ! -name "countries.json"))
    file_count=${#files[@]}
    if [ "$file_count" -lt 2 ]; then
        continue
    fi

    for ((i=0; i<$file_count; i++)); do
        baseline="${files[$i]}"
        baseline_keys=$(jq -r '. | keys[]' "$baseline" | sort)

        for ((j=i+1; j<$file_count; j++)); do
        file="${files[$j]}"
        file_keys=$(jq -r '. | keys[]' "$file" | sort)

        if [ "$baseline_keys" != "$file_keys" ]; then
            echo "Differences found between files in directory: $dir"
            diff=$(jq -r --argfile a "$baseline" --argfile b "$file" -n '$a as $old | $b as $new | [$old, $new] | map(keys) | flatten | unique | .[] as $key | {"key": $key, "old": $old[$key], "new": ($new[$key] // null)} | select((.old == null or .new == null) or (.old != .new and ((.old|test("\\[fr\\]|\\[it\\]|\\[FR\\]|\\[IT\\]")) or (.new?|test("\\[fr\\]|\\[it\\]|\\[FR\\]|\\[IT\\]"))))) | .key')
            echo "$diff in $dir$file" >> "$output_file"
        fi

        done
    done
    done

    awk '!seen[$0]++' "$output_file" > "$output_file.tmp" && mv "$output_file.tmp" "$output_file"
    cat "$output_file"
}

git-pull-all(){
    find . -type d -name ".git" -exec sh -c 'cd "{}" && cd .. && git pull' \;
}

#export NODE_TLS_REJECT_UNAUTHORIZED=1

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GPG_TTY=$(tty)
export REGISTRY_AUTH_FILE=/home/hr7/.podman/auth.json


export JAVA_HOME=/home/hr7/.sdkman/candidates/java/17.0.4-tem

alias mci='mvn clean install'
alias mcis='mvn clean install -DskipTests'
alias mcp='mvn clean package -DskipTests'
alias mcip='mvn clean install -Pintegration-test'
alias mcvs='mvn clean verify -U -DskipTests -T1.0C'
alias mcv='mvn clean verify'
alias ll="ls -lAhF"
alias up="~/.bash_scripts/up.sh"

curl -sS https://starship.rs/install.sh | sh

eval "$(starship init bash)"

#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash  1>/dev/null 2>/dev/null &
#nvm use 18.7 1>/dev/null 2>/dev/null &
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install 1>/dev/null 2>/dev/null &
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use 1>/dev/null 2>/dev/null &
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    nvm use default 1>/dev/null 2>/dev/null &
  fi
}
#load-nvmrc


curl -fsSL https://bun.sh/install | bash 

curl -fsSL https://deno.land/x/install/install.sh | sh 