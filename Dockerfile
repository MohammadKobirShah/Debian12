FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=7681 \
    USERNAME=1 \
    PASSWORD=1 \
    TERM=xterm-256color

# ── System Packages ───────────────────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        wget \
        curl \
        git \
        python3 \
        python3-pip \
        neofetch \
        screen \
        tmux \
        nano \
        vim \
        figlet \
        toilet \
        lolcat \
        nodejs \
        npm \
        htop \
        tree \
        zip \
        unzip \
        jq \
        ca-certificates \
        locales && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# ── TTYd Binary ───────────────────────────────────────────────────────────────
RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# ── Tmux Hacker Theme ─────────────────────────────────────────────────────────
RUN cat > /root/.tmux.conf <<'EOF'
set -g default-terminal "xterm-256color"
set -as terminal-overrides ",xterm-256color:Tc"

# ── Status Bar ────────────────────────────────────────────────────────────────
set -g status on
set -g status-interval 5
set -g status-position bottom
set -g status-style "bg=#0a0a0a,fg=#00ff00"

set -g status-left-length 60
set -g status-right-length 60

set -g status-left "#[fg=#00ff00,bold] ⚡ #[fg=#00cc00]HACKER-TERM #[fg=#00ff00]» #[fg=#00cc00][#S] "
set -g status-right "#[fg=#00cc00] 💻 #[fg=#00ff00,bold]%H:%M #[fg=#00cc00]| %d %b %Y "

set -g status-justify centre

# ── Windows ───────────────────────────────────────────────────────────────────
setw -g window-status-style "fg=#00aa00,bg=#0a0a0a"
setw -g window-status-current-style "fg=#000000,bg=#00ff00,bold"
setw -g window-status-format "  #I:#W  "
setw -g window-status-current-format "  #I:#W ●  "
setw -g window-status-separator ""

# ── Panes ─────────────────────────────────────────────────────────────────────
set -g pane-border-style "fg=#003300"
set -g pane-active-border-style "fg=#00ff00"
set -g pane-border-lines heavy

# ── Messages ──────────────────────────────────────────────────────────────────
set -g message-style "bg=#000000,fg=#00ff00,bold"
set -g message-command-style "bg=#000000,fg=#00ff00"

# ── General Settings ──────────────────────────────────────────────────────────
set -g mouse on
set -g base-index 1
set -g history-limit 50000
setw -g pane-base-index 1
set -g renumber-windows on
set -g set-titles on
set -g set-titles-string "⚡ HackerTerm | #W"
set -g display-time 2000
set -g focus-events on
setw -g aggressive-resize on

# ── Key Bindings ──────────────────────────────────────────────────────────────
bind r source-file ~/.tmux.conf \; display "⚡ Config Reloaded!"
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF

# ── Vim Hacker Theme ──────────────────────────────────────────────────────────
RUN cat > /root/.vimrc <<'EOF'
syntax on
set background=dark
set number
set relativenumber
set cursorline
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrap
set linebreak
set scrolloff=8
set sidescrolloff=8
set laststatus=2
set showmode
set showcmd
set wildmenu
set wildmode=list:longest
set mouse=a
set encoding=utf-8
set termguicolors
set clipboard=unnamed

" Hacker green color overrides
highlight Normal       ctermfg=46  ctermbg=0
highlight LineNr       ctermfg=34  ctermbg=0
highlight CursorLine   ctermbg=22  cterm=none
highlight CursorLineNr ctermfg=46  ctermbg=22 cterm=bold
highlight Comment      ctermfg=28
highlight Statement    ctermfg=46  cterm=bold
highlight String       ctermfg=40
highlight Constant     ctermfg=34
highlight StatusLine   ctermfg=0   ctermbg=46 cterm=bold
highlight StatusLineNC ctermfg=34  ctermbg=22
highlight Visual       ctermbg=22
highlight Search       ctermfg=0   ctermbg=46
highlight MatchParen   ctermfg=46  ctermbg=22 cterm=bold
EOF

# ── Nano Config ───────────────────────────────────────────────────────────────
RUN cat > /root/.nanorc <<'EOF'
set autoindent
set linenumbers
set mouse
set smooth
set tabsize 4
set tabstospaces
set trimblanks
set constantshow
set casesensitive
include "/usr/share/nano/*.nanorc"
EOF

# ── Main Bashrc ───────────────────────────────────────────────────────────────
RUN mkdir -p /root/.sessions /root/projects /root/.logs

RUN cat > /root/.bashrc <<'BASHRC'
# ═══════════════════════════════════════════════════════════════
#   HackerTerm  |  Developed by Kobir Shah
# ═══════════════════════════════════════════════════════════════

# ── History ──────────────────────────────────────────────────
export HISTFILE=/root/.bash_history
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%F %T  "
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"

# ── Environment ───────────────────────────────────────────────
export TERM=xterm-256color
export LANG=en_US.UTF-8
export EDITOR=nano
export VISUAL=nano

# ── Terminal Colors: Hacker Green ─────────────────────────────
printf '\033]11;#000000\007'
printf '\033]10;#00ff00\007'

# ── Git Branch ────────────────────────────────────────────────
parse_git_branch() {
    local branch
    branch=$(git branch 2>/dev/null | grep '\*' | sed 's/\* //')
    [ -n "$branch" ] && echo " ⎇ $branch"
}

parse_git_status() {
    local status
    status=$(git status --short 2>/dev/null | wc -l)
    [ "$status" -gt 0 ] 2>/dev/null && echo " ✗$status" || echo " ✓"
}

# ── Premium Two-Line Hacker Prompt ────────────────────────────
export PS1='\[\033[00;32m\]╔[\[\033[01;32m\]\u\[\033[00;32m\]@\[\033[01;32m\]\h\[\033[00;32m\]]-[\[\033[01;32m\]\w\[\033[00;32m\]]\[\033[01;33m\]$(parse_git_branch)\[\033[01;31m\]$(parse_git_status 2>/dev/null)\[\033[00;32m\] [\[\033[01;32m\]\t\[\033[00;32m\]]\n\[\033[00;32m\]╚══▶ \[\033[0m\]'

# ── Aliases ───────────────────────────────────────────────────
export LS_COLORS='di=01;32:fi=00;32:ln=01;36:ex=01;32:*.py=00;32:*.js=00;32:*.sh=01;32:'
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alFh --color=auto --group-directories-first'
alias la='ls -A --color=auto'
alias lt='tree -C --dirsfirst'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias cls='clear'
alias q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias top='htop'
alias wget='wget -c'
alias myip='curl -s https://ipinfo.io/ip && echo'
alias ports='ss -tulanp'
alias path='echo -e ${PATH//:/\\n}'
alias reload='source /root/.bashrc'
alias projects='cd /root/projects && ll'

# ── Functions ─────────────────────────────────────────────────

# Create dir and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1"    ;;
            *.tar.gz)  tar xzf "$1"    ;;
            *.tar.xz)  tar xJf "$1"    ;;
            *.bz2)     bunzip2 "$1"    ;;
            *.gz)      gunzip "$1"     ;;
            *.tar)     tar xf "$1"     ;;
            *.zip)     unzip "$1"      ;;
            *.7z)      7z x "$1"       ;;
            *)         echo "Cannot extract: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    echo -e "\033[01;32m⚡ Serving on http://localhost:${port}\033[0m"
    python3 -m http.server "$port"
}

# System info quick view
sysinfo() {
    echo -e "\033[01;32m"
    echo "  ┌─────────── SYSTEM INFO ───────────┐"
    printf "  │  %-10s : %-20s │\n" "Hostname"  "$(hostname)"
    printf "  │  %-10s : %-20s │\n" "Kernel"    "$(uname -r)"
    printf "  │  %-10s : %-20s │\n" "Uptime"    "$(uptime -p)"
    printf "  │  %-10s : %-20s │\n" "CPU"       "$(nproc) cores"
    printf "  │  %-10s : %-20s │\n" "Memory"    "$(free -h | awk '/^Mem/{print $3 "/" $2}')"
    printf "  │  %-10s : %-20s │\n" "Disk"      "$(df -h / | awk 'NR==2{print $3 "/" $2}')"
    printf "  │  %-10s : %-20s │\n" "IP"        "$(hostname -I | awk '{print $1}')"
    echo "  └───────────────────────────────────┘"
    echo -e "\033[0m"
}

# Help menu
help-me() {
    echo -e "\033[01;32m"
    echo "  ╔═══════════════════════════════════════════════════════╗"
    echo "  ║              ⚡  HACKERTERM REFERENCE  ⚡              ║"
    echo "  ╠═══════════════════╦═══════════════════════════════════╣"
    echo "  ║  TMUX             ║  COMMAND                          ║"
    echo "  ╠═══════════════════╬═══════════════════════════════════╣"
    echo "  ║  New Session      ║  tmux new -s name                 ║"
    echo "  ║  List Sessions    ║  tmux ls                          ║"
    echo "  ║  Attach Session   ║  tmux attach -t name              ║"
    echo "  ║  Detach           ║  Ctrl+B then D                    ║"
    echo "  ║  Split Vertical   ║  Ctrl+B then |                    ║"
    echo "  ║  Split Horizontal ║  Ctrl+B then -                    ║"
    echo "  ║  Move Panes       ║  Ctrl+B + H/J/K/L                 ║"
    echo "  ║  New Window       ║  Ctrl+B then C                    ║"
    echo "  ║  Reload Config    ║  Ctrl+B then R                    ║"
    echo "  ╠═══════════════════╬═══════════════════════════════════╣"
    echo "  ║  CUSTOM COMMANDS  ║  DESCRIPTION                      ║"
    echo "  ╠═══════════════════╬═══════════════════════════════════╣"
    echo "  ║  sysinfo          ║  System resource overview         ║"
    echo "  ║  myip             ║  Show public IP address           ║"
    echo "  ║  serve [port]     ║  Start HTTP server                ║"
    echo "  ║  mkcd [dir]       ║  Make dir and enter               ║"
    echo "  ║  extract [file]   ║  Extract any archive              ║"
    echo "  ║  projects         ║  Go to projects folder            ║"
    echo "  ║  ports            ║  Show open ports                  ║"
    echo "  ║  reload           ║  Reload bashrc                    ║"
    echo "  ╚═══════════════════╩═══════════════════════════════════╝"
    echo -e "\033[0m"
}

# ═════════════════════════════════════════════════════════════════
#   PREMIUM HACKER TUI WELCOME BANNER
# ═════════════════════════════════════════════════════════════════

clear
printf '\033[40m\033[2J\033[H'

G="\033[01;32m"   # bright green
g="\033[00;32m"   # dim green
Y="\033[01;33m"   # yellow
C="\033[00;36m"   # cyan
R="\033[00m"      # reset
B="\033[01;30m"   # dark gray

echo -e "${G}"
echo "  ╔══════════════════════════════════════════════════════════════════════╗"
echo "  ║                                                                      ║"
echo "  ║   ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗                  ║"
echo "  ║   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗                 ║"
echo "  ║   ███████║███████║██║     █████╔╝ █████╗  ██████╔╝                 ║"
echo "  ║   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗                 ║"
echo "  ║   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║                 ║"
echo "  ║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                 ║"
echo "  ║                                                                      ║"
echo "  ║   ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     ║"
echo "  ║      ██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     ║"
echo "  ║      ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     ║"
echo "  ║      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     ║"
echo "  ║      ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗║"
echo "  ║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝║"
echo "  ║                                                                      ║"
echo "  ╠══════════════════════════════════════════════════════════════════════╣"
echo -e "  ║  ${Y}  ⚡  SYSTEM ENVIRONMENT                                           ${G}║"
echo "  ╠══════════════════════════════════════════════════════════════════════╣"

printf "  ${G}║${g}  %-6s  ${G}│${g}  %-10s  ${G}│${g}  %-6s  ${G}│${g}  %-10s  ${G}│${g}  %-6s  ${G}│${g}  %-6s      ${G}║${R}\n" \
    "Node" "$(node --version 2>/dev/null || echo 'N/A')" \
    "Python" "$(python3 --version 2>/dev/null | awk '{print $2}')" \
    "NPM" "$(npm --version 2>/dev/null || echo 'N/A')"

printf "  ${G}║${g}  %-6s  ${G}│${g}  %-10s  ${G}│${g}  %-6s  ${G}│${g}  %-10s  ${G}│${g}  %-6s  ${G}│${g}  %-6s      ${G}║${R}\n" \
    "Git" "$(git --version 2>/dev/null | awk '{print $3}')" \
    "Shell" "$(bash --version | head -1 | awk '{print $4}')" \
    "CPU" "$(nproc) cores"

echo -e "${G}  ╠══════════════════════════════════════════════════════════════════════╣"
echo -e "  ║  ${Y}  📊  RESOURCES                                                      ${G}║"
echo "  ╠══════════════════════════════════════════════════════════════════════╣"

printf "  ${G}║${g}  💾  Memory  : ${G}%-20s${g}  🖥  CPU Cores : ${G}%-14s${G}║${R}\n" \
    "$(free -h | awk '/^Mem/{print $3 "/" $2}')" \
    "$(nproc)"

printf "  ${G}║${g}  💿  Disk    : ${G}%-20s${g}  🌐  IP Addr   : ${G}%-14s${G}║${R}\n" \
    "$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')" \
    "$(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"

printf "  ${G}║${g}  ⏱  Uptime  : ${G}%-20s${g}  📅  Date      : ${G}%-14s${G}║${R}\n" \
    "$(uptime -p 2>/dev/null | sed 's/up //')" \
    "$(date '+%d %b %Y')"

echo -e "${G}  ╠══════════════════════════════════════════════════════════════════════╣"
echo -e "  ║  ${C}  💡  Type [ help-me ] for command reference                         ${G}║"
echo -e "  ║  ${C}  🔒  Session is persistent — safe to close the browser              ${G}║"
echo -e "  ║  ${C}  📁  Projects folder: /root/projects                                ${G}║"
echo "  ╠══════════════════════════════════════════════════════════════════════╣"
echo -e "  ║                                                                      ║"
echo -e "  ║      ${g}Developed with ${G}💚${g} by  ${G}░▒▓  Kobir Shah  ▓▒░                      ${G}║"
echo -e "  ║      ${g}GitHub  »  ${G}github.com/MohammadKobirShah                                  ${G}║"
echo -e "  ║      ${g}Version »  ${G}HackerTerm v2.0                                      ${G}║"
echo "  ║                                                                      ║"
echo "  ╚══════════════════════════════════════════════════════════════════════╝"
echo -e "${R}"

cd /root
BASHRC

# ── Startup Script ────────────────────────────────────────────────────────────
RUN cat > /start.sh <<'EOF'
#!/bin/bash

SESSION_NAME="main"

# Log startup time
echo "[$(date '+%Y-%m-%d %H:%M:%S')] HackerTerm starting..." >> /root/.logs/startup.log

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" /bin/bash
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] New session created: $SESSION_NAME" >> /root/.logs/startup.log
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reattaching session: $SESSION_NAME" >> /root/.logs/startup.log
fi

exec ttyd \
    -p "${PORT}" \
    -c "${USERNAME}:${PASSWORD}" \
    -W \
    --title "⚡ HackerTerm | Kobir Shah" \
    tmux attach-session -t "$SESSION_NAME"
EOF

RUN chmod +x /start.sh

EXPOSE 7681

CMD ["/start.sh"]
