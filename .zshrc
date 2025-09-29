#!/bin/bash
# ===================================================================
# Powerlevel10k Instant Prompt (keep this as the very first block)
# ===================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# ===================================================================
# Shell checks
# ===================================================================
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# ===================================================================
# PATH
# ===================================================================
export PATH="$HOME/.local/bin/scripts:$PATH"
# ===================================================================
# Prompt (fallback if p10k not loaded)
# ===================================================================
PROMPT='[%n@%m %1~]$ '
# ===================================================================
# Functions
# ===================================================================
# Change directory to the last directory visited in lf
lfcd() {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [[ -f "$tmp" ]]; then
        dir="$(<"$tmp")"
        rm -f "$tmp"
        [[ -d "$dir" ]] && cd "$dir"
    fi
}
bindkey -s '^F' 'lfcd\n'
# ===================================================================
# Zinit Plugin Manager
# ===================================================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Plugin Manager...%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{34}Installation successful.%f" || \
        print -P "%F{160} The clone has failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ===================================================================
# Plugins
# ===================================================================
# Load annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Common plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode
# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
# zinit snippet OMZP::tmuxinator
zinit snippet OMZP::docker
zinit snippet OMZP::command-not-found
#######################################################
# ZSH Keybindings
#######################################################
bindkey -v
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# bindkey '^[w' kill-region
# bindkey ' ' magic-space                           # do history expansion on space
bindkey "^[[A" history-beginning-search-backward  # search history with up key
bindkey "^[[B" history-beginning-search-forward   # search history with down key

# Disable the cursor style feature
 ZVM_CURSOR_STYLE_ENABLED=true
 ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
 ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
 ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE


# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#######################################################
# ZSH Basic Options
#######################################################

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

#######################################################
# Environment Variables
#######################################################
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox-developer-edition

if command -v bat >/dev/null 2>&1; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export PAGER=bat
fi

man() {
    if command -v tldr >/dev/null 2>&1 && tldr "$1" >/dev/null 2>&1; then
        # pretty tldr output
        tldr --color=always "$@"
    else
        # fallback to real man (with bat pager)
        command man "$@"
    fi
}

if [[ -x "$(command -v fzf)" ]]; then
	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --info=inline-right \
	  --ansi \
	  --layout=reverse \
	  --border=rounded \
	  --color=border:#27a1b9 \
	  --color=fg:#c0caf5 \
	  --color=gutter:#16161e \
	  --color=header:#ff9e64 \
	  --color=hl+:#2ac3de \
	  --color=hl:#2ac3de \
	  --color=info:#545c7e \
	  --color=marker:#ff007c \
	  --color=pointer:#ff007c \
	  --color=prompt:#2ac3de \
	  --color=query:#c0caf5:regular \
	  --color=scrollbar:#27a1b9 \
	  --color=separator:#ff9e64 \
	  --color=spinner:#ff007c \
	"
fi

#######################################################
# History Configuration
#######################################################

HISTSIZE=10000
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

#######################################################
# Completion styling
#######################################################

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

#######################################################
# Add Common Binary Directories to Path
#######################################################

# Add directories to the end of the path if they exist and are not already in the path
# Link: https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
function pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

# Add directories to the beginning of the path if they exist and are not already in the path
function pathprepend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}


# ===================================================================
# Aliases
# ===================================================================
alias lf='lfub'
alias vim='nvim'
alias cdwm='vim ~/.config/dwm/config.h'
alias cdb='vim ~/.config/dwmblocks/blocks.h'
alias cdst='vim ~/.config/st/config.h'
alias cds='cd ~/.local/bin/scripts/; ls'
alias c='clear'
alias cc='clear && fastfetch'
alias grep='grep --color=auto'
alias mdwm='cd ~/.config/dwm; sudo make clean install; cd -'
alias mdb='cd ~/.config/dwmblocks; sudo make clean install; cd -'
alias mdst='cd ~/.config/st; sudo make clean install; cd -'
alias q='exit'
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rec='~/.local/bin/scripts/recorder.sh'
alias ssh="nocorrect ssh"

#----- Vim Editing modes & keymaps ------ 
set -o vi
# Alias for neovim
if [[ -x "$(command -v nvim)" ]]; then
	alias vi='nvim'
	alias vim='nvim'
	alias svim='sudo nvim'
	alias vis='nvim "+set si"'
elif [[ -x "$(command -v vim)" ]]; then
	alias vi='vim'
	alias svim='sudo vim'
	alias vis='vim "+set si"'
fi

# Aliases for eza (modern ls replacement)
if command -v eza >/dev/null 2>&1; then
	alias ls='eza -F --icons --group-directories-first'
	alias ll='eza -alh --group-directories-first --header --long --icons'
	alias tree='eza --tree --icons'
fi

# git aliases
alias gt="git"
alias ga="git add"
alias gs="git status"
alias gc='git commit -m'
alias gm='git merge'
alias gco='git checkout'
alias gst='git stash'
alias glog='git log --oneline --graph --all'
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'

# Tmux 
alias tmux f="tmux -f $TMUX_CONF"
alias a="attach"
# calls the tmux new session script
alias tns="~/.local/bin/scripts/tmux-sessionizer"

source ~/.local/bin/scripts/fzf-git.sh

# fzf 
# called from ~/.local/bin/scripts/
alias nlof="~/.local/bin/scripts/fzf_listoldfiles.sh"
# opens documentation through fzf (eg: git,zsh etc.)
fman() {
    if [ $# -eq 0 ]; then
        # No argument → fuzzy select a command
        cmd="$(compgen -c | sort -u | fzf --preview 'man {} | col -bx | head -50')"
        [ -n "$cmd" ] && man "$cmd"

    elif [ "$1" = "-s" ] && [ -n "$2" ]; then
        # Search mode → find keyword in manpages
        shift
        entry="$(man -k "$@" | fzf --preview 'echo {} | awk "{print \$1}" | xargs -r man | col -bx | head -50')"
        [ -n "$entry" ] && man $(echo "$entry" | awk '{print $1}')
        
    else
        # With argument(s) → open directly
        man "$@"
    fi
}

# zoxide (called from ~/.local/bin/scripts/)
alias nzo="~/.local/bin/scripts/zoxide_openfiles_nvim.sh"

if command -v xdg-open >/dev/null 2>&1; then
	alias open='xdg-open &>/dev/null &'
fi

# Alias to launch a PDF in Zathura
if command -v zathura >/dev/null 2>&1; then
    alias pdf='zathura'
fi
# Alias For bat
# Link: https://github.com/sharkdp/bat
if [[ -x "$(command -v bat)" ]]; then
    alias cat='bat'
fi

# Alias for lazygit
# Link: https://github.com/jesseduffield/lazygit
if [[ -x "$(command -v lazygit)" ]]; then
    alias lg='lazygit'
fi

# Alias for FZF
# Link: https://github.com/junegunn/fzf
if [[ -x "$(command -v fzf)" ]]; then
    alias fzf='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
    # Alias to fuzzy find files in the current folder(s), preview them, and launch in an editor
	if [[ -x "$(command -v xdg-open)" ]]; then
		alias preview='open $(fzf --info=inline --query="${@}")'
	else
		alias preview='edit $(fzf --info=inline --query="${@}")'
	fi
fi

# Get local IP addresses
if [[ -x "$(command -v ip)" ]]; then
    alias iplocal="ip -br -c a"
else
    alias iplocal="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
fi

# Get public IP addresses
if [[ -x "$(command -v curl)" ]]; then
    alias ipexternal="curl -s ifconfig.me && echo"
elif [[ -x "$(command -v wget)" ]]; then
    alias ipexternal="wget -qO- ifconfig.me && echo"
fi

#######################################################
# Functions (Linux)
#######################################################

# Start a program, disown it, and detach from terminal
runfree() {
    "$@" &>/dev/null & disown
}


. ~/.local/bin/scripts/notify.sh   # load notification functions

# Copy file with a progress bar (rsync preferred, fallback to cp + pv)
cpp() {
    local src="$1" dst="$2"

    if command -v rsync >/dev/null 2>&1; then
        if rsync -ah --info=progress2 "$src" "$dst"; then
            notify_success "Copy" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Copy" "Failed: $(basename "$src")"
        fi
    elif command -v pv >/dev/null 2>&1; then
        if pv "$src" > "$dst"; then
            notify_success "Copy" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Copy" "Failed: $(basename "$src")"
        fi
    else
        if cp "$src" "$dst"; then
            notify_success "Copy" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Copy" "Failed: $(basename "$src")"
        fi
    fi
}

# Copy file and go to the target directory
cpg() {
    local src="$1" dst="$2"

    if [[ -d "$dst" ]]; then
        if cp "$src" "$dst" && cd "$dst"; then
            notify_success "Copy" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Copy" "Failed: $(basename "$src")"
        fi
    else
        if cp "$src" "$dst"; then
            notify_success "Copy" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Copy" "Failed: $(basename "$src")"
        fi
    fi
}

# Move file and go to the target directory
mvg() {
    local src="$1" dst="$2"

    if [[ -d "$dst" ]]; then
        if mv "$src" "$dst" && cd "$dst"; then
            notify_success "Move" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Move" "Failed: $(basename "$src")"
        fi
    else
        if mv "$src" "$dst"; then
            notify_success "Move" "$(basename "$src") → $(basename "$dst")"
        else
            notify_error "Move" "Failed: $(basename "$src")"
        fi
    fi
}

# Create directory and immediately enter it
mkdirg() {
    if mkdir -p "$@" && cd "$@"; then
        notify_success "Directory" "Created and entered $*"
    else
        notify_error "Directory" "Failed to create $*"
    fi
}

# Print random height bars across terminal width (fun for `lolcat`)
random_bars() {
    local columns chars
    columns=$(tput cols)
    chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
    for ((i=1; i<=columns; i++)); do
        echo -n "${chars[RANDOM % ${#chars[@]}]}"
    done
    echo
}
eval "$(zoxide init zsh)"

#FZF
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMANDS="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_COMMANDS="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Setup FZF preview
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

#######################################################
# Shell integrations
#######################################################

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
