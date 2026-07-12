FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=7681 \
    USERNAME=1 \
    PASSWORD=1 \
    TERM=xterm-256color \
    SSH_PORT=22

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
        openssh-client \
        openssh-server \
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

# ── SSH Server Setup ──────────────────────────────────────────────────────────
RUN mkdir -p /run/sshd /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo 'root:${PASSWORD}' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    echo "AllowUsers root" >> /etc/ssh/sshd_config && \
    ssh-keygen -A

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
set -g status-left "#[fg=#00ff00,bold] [*] #[fg=#00cc00]HACKER-TERM #[fg=#00ff00]>> #[fg=#00cc00][#S] "
set -g status-right "#[fg=#00cc00] [>] #[fg=#00ff00,bold]%H:%M #[fg=#00cc00]| %d %b %Y "
set -g status-justify centre

# ── Windows ───────────────────────────────────────────────────────────────────
setw -g window-status-style "fg=#00aa00,bg=#0a0a0a"
setw -g window-status-current-style "fg=#000000,bg=#00ff00,bold"
setw -g window-status-format "  #I:#W  "
setw -g window-status-current-format "  #I:#W [+]  "
setw -g window-status-separator ""

# ── Panes ─────────────────────────────────────────────────────────────────────
set -g pane-border-style "fg=#003300"
set -g pane-active-border-style "fg=#00ff00"
set -g pane-border-lines heavy

# ── Messages ──────────────────────────────────────────────────────────────────
set -g message-style "bg=#000000,fg=#00ff00,bold"
set -g message-command-style "bg=#000000,fg=#00ff00"

# ── General ───────────────────────────────────────────────────────────────────
set -g mouse on
set -g base-index 1
set -g history-limit 50000
setw -g pane-base-index 1
set -g renumber-windows on
set -g set-titles on
set -g set-titles-string "HackerTerm | #W"
set -g display-time 2000
set -g focus-events on
setw -g aggressive-resize on

# ── Key Bindings ──────────────────────────────────────────────────────────────
bind r source-file ~/.tmux.conf \; display "[*] Config Reloaded!"
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
# =============================================================================
#   HackerTerm v2.0  |  Developed by Kobir Shah
# =============================================================================

# ── History ───────────────────────────────────────────────────────────────────
export HISTFILE=/root/.bash_history
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%F %T  "
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"

# ── Environment ───────────────────────────────────────────────────────────────
export TERM=xterm-256color
export LANG=en_US.UTF-8
export EDITOR=nano
export VISUAL=nano

# ── Terminal Colors: Hacker Green on Black ────────────────────────────────────
printf '\033]11;#000000\007'
printf '\033]10;#00ff00\007'

# ── Color Variables ───────────────────────────────────────────────────────────
GREEN='\033[01;32m'
DGREEN='\033[00;32m'
YELLOW='\033[01;33m'
CYAN='\033[00;36m'
RESET='\033[0m'
DGRAY='\033[01;30m'

# ── Git Helpers ───────────────────────────────────────────────────────────────
parse_git_branch() {
    local branch
    branch=$(git branch 2>/dev/null | grep '\*' | sed 's/\* //')
    [ -n "$branch" ] && echo " ($branch)"
}

parse_git_dirty() {
    local count
    count=$(git status --short 2>/dev/null | wc -l)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        [ "$count" -gt 0 ] && echo " [!${count}]" || echo " [OK]"
    fi
}

# ── Two-Line Hacker Prompt ────────────────────────────────────────────────────
export PS1='\[\033[00;32m\]╔[\[\033[01;32m\]\u\[\033[00;32m\]@\[\033[01;32m\]\h\[\033[00;32m\]]-[\[\033[01;32m\]\w\[\033[00;32m\]]\[\033[01;33m\]$(parse_git_branch)\[\033[01;31m\]$(parse_git_dirty)\[\033[00;32m\]-[\[\033[01;32m\]\t\[\033[00;32m\]]\n\[\033[00;32m\]╚══> \[\033[0m\]'

# ── Aliases ───────────────────────────────────────────────────────────────────
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

# ── Functions ─────────────────────────────────────────────────────────────────

mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1"  ;;
            *.gz)      gunzip "$1"   ;;
            *.tar)     tar xf "$1"   ;;
            *.zip)     unzip "$1"    ;;
            *.7z)      7z x "$1"     ;;
            *)         echo "[-] Cannot extract: $1" ;;
        esac
    else
        echo "[-] File not found: $1"
    fi
}

serve() {
    local port="${1:-8000}"
    echo -e "${GREEN}[*] Serving on http://localhost:${port}${RESET}"
    python3 -m http.server "$port"
}

sysinfo() {
    echo -e "${GREEN}"
    echo "  .----------------------------------."
    echo "  |        SYSTEM INFORMATION        |"
    echo "  |----------------------------------|"
    printf "  |  %-10s : %-18s|\n" "Hostname"  "$(hostname)"
    printf "  |  %-10s : %-18s|\n" "Kernel"    "$(uname -r | cut -c1-18)"
    printf "  |  %-10s : %-18s|\n" "Uptime"    "$(uptime -p | sed 's/up //' | cut -c1-18)"
    printf "  |  %-10s : %-18s|\n" "CPU Cores" "$(nproc) cores"
    printf "  |  %-10s : %-18s|\n" "Memory"    "$(free -h | awk '/^Mem/{print $3"/"$2}')"
    printf "  |  %-10s : %-18s|\n" "Disk"      "$(df -h / | awk 'NR==2{print $3"/"$2}')"
    printf "  |  %-10s : %-18s|\n" "Local IP"  "$(hostname -I | awk '{print $1}')"
    echo "  '----------------------------------'"
    echo -e "${RESET}"
}

help-me() {
    echo -e "${GREEN}"
    echo "  .=======================================================."
    echo "  |           [*]  HACKERTERM REFERENCE  [*]              |"
    echo "  |=======================-================================|"
    echo "  |  TMUX COMMANDS         |  ACTION                      |"
    echo "  |------------------------|------------------------------|"
    echo "  |  tmux new -s name      |  Create new session          |"
    echo "  |  tmux ls               |  List all sessions           |"
    echo "  |  tmux attach -t name   |  Attach to session           |"
    echo "  |  Ctrl+B then D         |  Detach from session         |"
    echo "  |  Ctrl+B then |         |  Split pane vertical         |"
    echo "  |  Ctrl+B then -         |  Split pane horizontal       |"
    echo "  |  Ctrl+B + H/J/K/L      |  Move between panes          |"
    echo "  |  Ctrl+B then C         |  New window                  |"
    echo "  |  Ctrl+B then R         |  Reload tmux config          |"
    echo "  |========================|==============================|"
    echo "  |  CUSTOM COMMANDS       |  DESCRIPTION                 |"
    echo "  |------------------------|------------------------------|"
    echo "  |  sysinfo               |  System resource overview    |"
    echo "  |  myip                  |  Show public IP address      |"
    echo "  |  serve [port]          |  Start HTTP file server      |"
    echo "  |  mkcd [dir]            |  Make dir and enter it       |"
    echo "  |  extract [file]        |  Extract any archive         |"
    echo "  |  projects              |  Go to /root/projects        |"
    echo "  |  ports                 |  Show open ports             |"
    echo "  |  reload                |  Reload .bashrc config       |"
    echo "  |  help-me               |  Show this help menu         |"
    echo "  '======================================================='  "
    echo -e "${RESET}"
}

# =============================================================================
#   PREMIUM HACKER TUI - WELCOME SCREEN
# =============================================================================

_show_banner() {

    clear
    printf '\033[40m\033[2J\033[H'

    local G="\033[01;32m"
    local g="\033[00;32m"
    local Y="\033[01;33m"
    local C="\033[01;36m"
    local R="\033[0m"
    local D="\033[02;32m"

    # collect system info first
    local NODE_V  PY_V  NPM_V  GIT_V  MEM  DISK  CPU  IP  UPTIME  DATE_V  SHELL_V
    NODE_V=$(node   --version  2>/dev/null || echo "N/A")
    PY_V=$(python3  --version  2>/dev/null | awk '{print $2}' || echo "N/A")
    NPM_V=$(npm     --version  2>/dev/null || echo "N/A")
    GIT_V=$(git     --version  2>/dev/null | awk '{print $3}' || echo "N/A")
    MEM=$(free   -h 2>/dev/null | awk '/^Mem/{print $3"/"$2}')
    DISK=$(df    -h /          | awk 'NR==2{print $3"/"$2" ("$5")"}')
    CPU="$(nproc) cores"
    IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    UPTIME=$(uptime -p 2>/dev/null | sed 's/up //')
    DATE_V=$(date '+%d %b %Y  %H:%M')
    SHELL_V=$(bash --version | head -1 | awk '{print $4}')

    echo -e "${G}"
    echo "  +========================================================================+"
    echo "  |                                                                        |"
    echo "  |   ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗                    |"
    echo "  |   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗                   |"
    echo "  |   ███████║███████║██║     █████╔╝ █████╗  ██████╔╝                   |"
    echo "  |   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗                   |"
    echo "  |   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║                   |"
    echo "  |   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                   |"
    echo "  |                                                                        |"
    echo "  |   ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗       |"
    echo "  |      ██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║       |"
    echo "  |      ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║       |"
    echo "  |      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║       |"
    echo "  |      ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗  |"
    echo "  |      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝  |"
    echo "  |                                                                        |"
    echo "  +========================================================================+"
    echo -e "  | ${Y}  [*] DEVELOPMENT ENVIRONMENT                                       ${G}|"
    echo "  +==================+============+==================+====================+"
    printf "  ${G}|${g} [>] Node.js : ${G}%-9s ${g}|${G}${g} [>] Python : ${G}%-9s ${g}|${G}${g} [>] NPM    : ${G}%-9s ${g}${G}|${R}\n" \
        "$NODE_V" "$PY_V" "v$NPM_V"
    printf "  ${G}|${g} [>] Git    : ${G}%-9s ${g}|${G}${g} [>] Shell  : ${G}%-9s ${g}|${G}${g} [>] CPU    : ${G}%-9s ${g}${G}|${R}\n" \
        "$GIT_V" "$SHELL_V" "$CPU"
    echo -e "${G}  +==================+============+==================+====================+"
    echo -e "  | ${Y}  [*] SYSTEM RESOURCES                                               ${G}|"
    echo "  +===================================+====================================+"
    printf "  ${G}|${g} [+] Memory  : ${G}%-20s ${g}${G}|${g} [+] Disk    : ${G}%-18s ${g}${G}|${R}\n" \
        "$MEM" "$DISK"
    printf "  ${G}|${g} [+] Uptime  : ${G}%-20s ${g}${G}|${g} [+] Date    : ${G}%-18s ${g}${G}|${R}\n" \
        "$UPTIME" "$DATE_V"
    printf "  ${G}|${g} [+] Local IP: ${G}%-20s ${g}${G}|${g} [+] Host    : ${G}%-18s ${g}${G}|${R}\n" \
        "$IP" "$(hostname)"
    echo -e "${G}  +===================================+====================================+"
    echo -e "  | ${C}  [!] Type [ help-me ] for full command reference                     ${G}|"
    echo -e "  | ${C}  [!] Session is persistent -- safe to close the browser              ${G}|"
    echo -e "  | ${C}  [!] Projects dir: /root/projects                                    ${G}|"
    echo "  +========================================================================+"
    echo -e "  |                                                                        |"
    echo -e "  |    ${g}Developed with <3 by ${G}>>> Kobir Shah <<<                           ${G}|"
    echo -e "  |    ${g}GitHub  >>  ${G}github.com/MohammadKobirShah                                  ${G}|"
    echo -e "  |    ${g}Version >>  ${G}HackerTerm v2.0  [ $(date '+%Y') ]                           ${G}|"
    echo "  |                                                                        |"
    echo "  +========================================================================+"
    echo -e "${R}"
}

_show_banner

cd /root
BASHRC

# ── Tmate Binary (Instant Public URLs) ────────────────────────────────────────
RUN wget -qO /tmp/tmate.tar.xz \
    https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz && \
    tar -xf /tmp/tmate.tar.xz -C /tmp && \
    mv /tmp/tmate-2.4.0-static-linux-amd64/tmate /usr/local/bin/tmate && \
    chmod +x /usr/local/bin/tmate && \
    rm -rf /tmp/tmate*

# ── sshx Binary (Collaborative Terminal Sharing) ─────────────────────────────
RUN wget -qO /usr/local/bin/sshx \
    https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl && \
    chmod +x /usr/local/bin/sshx

# ── WebSSH Server ─────────────────────────────────────────────────────────────
COPY webssh /webssh
RUN cd /webssh && npm install
ENV WEBSSH_PORT=3000

# ── Startup Script ────────────────────────────────────────────────────────────
RUN cat > /start.sh <<'EOF'
#!/bin/bash

SESSION_NAME="main"

mkdir -p /root/.logs /root/.ssh
chmod 700 /root/.ssh

# Set root password dynamically
echo "root:${PASSWORD}" | chpasswd

# Inject SSH public key if provided
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] HackerTerm starting..." >> /root/.logs/startup.log

# Start SSH daemon
/usr/sbin/sshd -p "${SSH_PORT}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SSH daemon started on port ${SSH_PORT}" >> /root/.logs/startup.log

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" /bin/bash
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] New tmux session created: $SESSION_NAME" >> /root/.logs/startup.log
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reattaching existing session: $SESSION_NAME" >> /root/.logs/startup.log
fi

# Start WebSSH server in background
cd /webssh
node server.js >> /root/.logs/webssh.log 2>&1 &
echo "[$(date '+%Y-%m-%d %H:%M:%S')] WebSSH started on port ${WEBSSH_PORT}" >> /root/.logs/startup.log

# ── Tmate Public Tunnel ──────────────────────────────────────────────────────
(
    sleep 5
    TMATE_SOCK=/tmp/tmate.sock
    tmate -S "$TMATE_SOCK" new-session -d -s tmate -n public bash
    tmate -S "$TMATE_SOCK" wait tmate-ready
    echo "" >> /root/.logs/startup.log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ═══ TMATE PUBLIC URLS ═══" >> /root/.logs/startup.log
    echo "SSH:  $(tmate -S "$TMATE_SOCK" display -p '#{tmate_ssh}')" >> /root/.logs/startup.log
    echo "WEB:  $(tmate -S "$TMATE_SOCK" display -p '#{tmate_web}')" >> /root/.logs/startup.log
    echo "READ: $(tmate -S "$TMATE_SOCK" display -p '#{tmate_ssh_ro}')" >> /root/.logs/startup.log
    echo "═══════════════════════════════════════" >> /root/.logs/startup.log
) &

# ── sshx Collaborative Session ───────────────────────────────────────────────
(
    sleep 8
    echo "" >> /root/.logs/startup.log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ═══ SSHX COLLAB URL ═══" >> /root/.logs/startup.log
    sshx --quiet >> /root/.logs/sshx.log 2>&1 &
    sleep 3
    cat /root/.logs/sshx.log >> /root/.logs/startup.log
    echo "═══════════════════════════════════════" >> /root/.logs/startup.log
) &

exec ttyd \
    -p "${PORT}" \
    -c "${USERNAME}:${PASSWORD}" \
    -W \
    tmux attach-session -t "$SESSION_NAME"
EOF

RUN chmod +x /start.sh

EXPOSE 22 7681 3000

CMD ["/start.sh"]
