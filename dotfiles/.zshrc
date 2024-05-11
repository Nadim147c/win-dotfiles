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

export FZF_DEFAULT_OPTS='
--color=fg:#cdd6f4,header:#a6e3a1,info:#94e2d5,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#94e2d5,hl+:#a6e3a1
--info inline-right --layout reverse
'

plugins=(
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

alias reload='clear && source ~/.zshrc'
alias config='nvim ~/.zshrc'
alias stdn='sudo shutdown now'
alias eh='nvim ~/.zsh_history'

alias fix-mod-ig-idk='sudo chmod -R 777 /media/media/movie && sudo chmod -R 777 /media/media/show'

alias song='spdl --write-lrc --write-m3u --sleep-time 0.5 --no-subdir --output /media/media/music/'

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
alias gs='git status'
alias gi='git status | rg '\''\w+: *.+'\'' | fzf --delimiter ':' --preview '\''git diff --color=always {2}'\''

alias video='yt-dlp -f '\''bv*[height<=1080]+ba/b'\'' --merge-output-format mp4 --add-metadata --embed-chapters --list-formats --no-simulate --sponsorblock-remove all'
alias video720="yt-dlp -f 'bv*[height<=720]+ba/b' --merge-output-format mp4 --add-metadata --embed-chapters --list-formats --no-simulate --sponsorblock-remove all"

alias hh='cat ~/.zsh_history | fzf | awk -F ; '\''{print \$2}'\'' | bash'

echo -e '
\033[0;32m _____ ____  _   _ _____ __  __ _____ ____      _    _     
| ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
|  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
| |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
|_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|
'

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"


