dttc () {
    local filename="$1"
    extension=$(echo "$filename" | grep -o '\.[^.]*$')
    filename_no_ext=$(echo "$filename" | sed 's/\.[^.]*$//' | sed 's/\./ /g' | awk '{ for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); }1' | tr ' ' '\n' | tr '\n' ' ' | sed 's/ $//')

    echo "From:$1"
    echo "To:$filename_no_ext$extension"

    mv $1 "$filename_no_ext$extension"
} 

apt() { 
    if [[ "$1" == "install" || "$1" == "update" || "$1" == "upgrade" ]]; then
        command sudo nala "$@"
    else 
        command nala "$@"
    fi
}

nala() { 
    if [[ "$1" == "install" || "$1" == "update" || "$1" == "upgrade" ]]; then
        command sudo nala "$@"
    else 
        command nala "$@"
    fi
}

export ZSH="$HOME/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion alias zshconfig="mate ~/.zshrc"

export PATH="$PATH:/home/ephemeral/.local/bin"

plugins=(
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

## My aliases
alias ni="sudo nala install"
alias ud="sudo nala update"
alias ug="sudo nala upgrade"

alias dog='pygmentize -g -O style=colorful'

alias reload="clear && source ~/.zshrc"
alias config="nvim ~/.zshrc"
alias stdn="sudo shutdown now"
alias eh="nvim ~/.zsh_history"
alias vimconfig="nvim ~/.config/nvim/lua/custom/"

alias fix-mod-ig-idk='sudo chmod -R 777 /media/media/movie && sudo chmod -R 777 /media/media/show'

alias song='spdl --write-lrc --sleep-time 0.5 --no-subdir --output /media/media/music/'

#transmission client
alias rmtor='~/tools/remove-transmission-torrent.sh'
alias lstor='transmission-remote $(cat ~/tools/transmission.token) --list'

alias tma='tmux a -t $(tmux ls | fzf | awk -F: '\''{print $1}'\'')'
alias tmr='tmux kill-session -t $(tmux ls | fzf | awk -F: '\''{print $1}'\'')'
alias tmn='tmux new -s'

alias vim=nvim
alias n=pnpm
alias pm=pm2
alias gd=gallery-dl
alias yts=ytdl-sub
alias yt=yt-dlp

#Git 
alias gs="git status"

alias video="yt-dlp -f 'bv[height<=1080]+ba/b' --merge-output-format mp4 --add-metadata --embed-chapters --list-formats --no-simulate --sponsorblock-remove all"

alias hh="cat ~/.zsh_history | fzf | awk -F';' '{print \$2}' | bash"

echo -e '\033[0;32m _____ ____  _   _ _____ __  __ _____ ____      _    _     
| ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
|  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
| |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
|_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|
'

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"


