# Download Zinit, if it's not there yet
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
# Source/Load zinit
source "$ZINIT_HOME/zinit.zsh"

# Load custom shell command 
if [ -f "$HOME/.zsh_cmd" ]; then
    source "$HOME/.zsh_cmd" 
fi

# Exports 
export FZF_DEFAULT_OPTS='
--color=fg:#cdd6f4,header:#a6e3a1,info:#94e2d5,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#94e2d5,hl+:#a6e3a1
--info inline-right --layout reverse --border
'
export PATH="$PATH:/home/ephemeral/.local/bin:/usr/local/go/bin"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::sudo
zinit snippet OMZP::nvm
zinit snippet OMZP::thefuck
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::command-not-found

zstyle ':omz:plugins:nvm' lazy yes

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
export HISTSIZE=5000
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE
export HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color $realpath'

# Custom binding
bindkey -e
bindkey "^[[H" beginning-of-line                # Key Home
bindkey "^[[F" end-of-line                      # Key End
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# alias
alias reload='clear && source ~/.zshrc'
alias config='nvim ~/.zshrc'
alias stdn='sudo shutdown now'

# RUST_WRAPPER=sccache cargo install eza
# LS alias
alias ls='eza --color=always --icons'
alias l='eza --color=always --icons -ial'
alias la='eza --color=always --icons -ia'

# SPDL
alias song='spdl --write-lrc --write-m3u --sleep-time 0.5 --no-subdir --output /media/media/music/'

#transmission client
alias rmtor='~/tools/remove-transmission-torrent.sh'
alias lstor='transmission-remote $(cat ~/tools/transmission.token) --list'

# Zellij
alias za='zellij a $(zellij ls | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" | rg -v EXITED | fzf | awk '\''{print $1}'\'')'
alias zr='zellij kill-session $(zellij ls | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" | fzf | awk '\''{print $1}'\'')'
alias zda='zellij delete-all-sessions'
zn() { 
    if [ -n "$1" ];then
        zellij -s "$1" 
    else 
        echo 'Please pass session name as an argument' 
    fi
}


alias vim=nvim
alias n=pnpm
alias pm=pm2
alias yt=yt-dlp

# yt-dlp alias
alias video='yt-dlp -f '\''bv*[height<=1080]+ba/b'\'' --merge-output-format mp4 --add-metadata --embed-chapters --list-formats --no-simulate --sponsorblock-remove all'

echo -e '\033[0;32m
 _____ ____  _   _ _____ __  __ _____ ____      _    _     
| ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
|  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
| |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
|_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|
'

eval "$(starship init zsh)"
eval "$(thefuck --alias f)"
eval "$(zoxide init zsh --cmd cd)"
source <(fzf --zsh)
