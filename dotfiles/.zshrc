# Download Zinit, if it's not there yet
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load custom shell command 
if [ -f "$HOME/.zsh_cmd" ]; then
    source "$HOME/.zsh_cmd" 
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::sudo
zinit snippet OMZP::nvm
zinit snippet OMZP::common-aliases
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::command-not-found

zstyle ':omz:plugins:nvm' lazy yes

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
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
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Custom binding
bindkey -e
bindkey "^[[H" beginning-of-line                # Key Home
bindkey "^[[F" end-of-line                      # Key End
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Exports 
export FZF_DEFAULT_OPTS='
--color=fg:#cdd6f4,header:#a6e3a1,info:#94e2d5,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#94e2d5,hl+:#a6e3a1
--info inline-right --layout reverse
'
export PATH="$PATH:/home/ephemeral/.local/bin"

# alias
alias reload='clear && source ~/.zshrc'
alias config='nvim ~/.zshrc'
alias stdn='sudo shutdown now'

# LS alias
alias ls='ls --color=always'
alias la='ls --color=always -ian'
alias l='ls --color=always -in'

# SPDL
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
alias yt=yt-dlp

#Git 
alias gs='git status'

# yt-dlp alias
alias video='yt-dlp -f '\''bv*[height<=1080]+ba/b'\'' --merge-output-format mp4 --add-metadata --embed-chapters --list-formats --no-simulate --sponsorblock-remove all'

alias hh='cat ~/.zsh_history | fzf | awk -F ; '\''{print \$2}'\'' | bash'

echo -e '\033[0;32m
 _____ ____  _   _ _____ __  __ _____ ____      _    _     
| ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
|  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
| |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
|_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|
'

eval "$(starship init zsh)"
eval "$(thefuck --alias)"
eval "$(zoxide init zsh --cmd cd)"

eval $(thefuck --alias)
