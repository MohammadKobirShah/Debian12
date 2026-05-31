#!/bin/bash

# =============================================================================
#   HackerTerm v2.1 | Simple & Stable | Kobir Shah
# =============================================================================

GREEN='\033[00;32m'
BGREEN='\033[01;32m'
CYAN='\033[00;36m'
RESET='\033[0m'

echo -e "${BGREEN}[*] Starting HackerTerm Setup...${RESET}"

# ── 1. System Packages ───────────────────────────────────────────────────────
echo -e "${CYAN}[*] Installing packages...${RESET}"
apt-get update -y
apt-get install -y \
    bash wget curl git python3 \
    neofetch tmux nano htop \
    tree zip unzip jq

# ── 2. TTYd Download ─────────────────────────────────────────────────────────
echo -e "${CYAN}[*] Downloading ttyd...${RESET}"
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    TTYD_FILE="ttyd.aarch64"
else
    TTYD_FILE="ttyd.x86_64"
fi

wget -qO /usr/local/bin/ttyd \
    "https://github.com/tsl0922/ttyd/releases/download/1.7.7/${TTYD_FILE}"
chmod +x /usr/local/bin/ttyd

# ── 3. Directories ───────────────────────────────────────────────────────────
mkdir -p ~/projects ~/.logs

# ── 4. Tmux Config ───────────────────────────────────────────────────────────
cat > ~/.tmux.conf <<'EOF'
set -g default-terminal "xterm-256color"
set -g status on
set -g status-interval 5
set -g status-position bottom
set -g status-style "bg=#0a0a0a,fg=#00cc66"
set -g status-left "#[fg=#00cc66,bold] ⚡ #S >> "
set -g status-right "#[fg=#00cc66] %H:%M | %d %b "
set -g status-justify centre
setw -g window-status-style "fg=#008844,bg=#0a0a0a"
setw -g window-status-current-style "fg=#0a0a0a,bg=#00cc66,bold"
setw -g window-status-format "  #I:#W  "
setw -g window-status-current-format "  #I:#W  "
set -g pane-border-style "fg=#003322"
set -g pane-active-border-style "fg=#00cc66"
set -g mouse on
set -g history-limit 50000
bind r source-file ~/.tmux.conf \; display "Config Reloaded!"
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF

# ── 5. Nano Config ───────────────────────────────────────────────────────────
cat > ~/.nanorc <<'EOF'
set autoindent
set linenumbers
set mouse
set tabsize 4
set tabstospaces
set constantshow
include "/usr/share/nano/*.nanorc"
EOF

# ── 6. Bashrc ────────────────────────────────────────────────────────────────
echo -e "${CYAN}[*] Setting up shell...${RESET}"

cat > ~/.bashrc <<'BASHRC'
# =============================================================================
#   HackerTerm Shell | Kobir Shah
# =============================================================================

# ── History ──────────────────────────────────────────────────────────────────
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups
shopt -s histappend
shopt -s checkwinsize

# ── Environment ──────────────────────────────────────────────────────────────
export TERM=xterm-256color
export LANG=en_US.UTF-8
export EDITOR=nano

# ── Git Branch in Prompt ─────────────────────────────────────────────────────
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# ── Prompt ───────────────────────────────────────────────────────────────────
export PS1='\[\033[00;32m\]┌──(\[\033[01;32m\]\u@\h\[\033[00;32m\])-[\[\033[01;32m\]\w\[\033[00;32m\]]\[\033[00;36m\]$(parse_git_branch)\[\033[00;32m\]\n\[\033[00;32m\]└─\$ \[\033[0m\]'

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias lt='tree -C'
alias grep='grep --color=auto'
alias cls='clear'
alias q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'
alias myip='curl -s https://ipinfo.io/ip && echo'
alias ports='ss -tulanp'
alias reload='source ~/.bashrc'
alias projects='cd ~/projects && ll'

# ── Functions ─────────────────────────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1"; }

serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:${port}"
    python3 -m http.server "$port"
}

sysinfo() {
    echo ""
    printf "  %-10s : %s\n" "Host"   "$(hostname)"
    printf "  %-10s : %s\n" "OS"     "$(lsb_release -d | cut -f2)"
    printf "  %-10s : %s\n" "Kernel" "$(uname -r)"
    printf "  %-10s : %s\n" "CPU"    "$(nproc) cores"
    printf "  %-10s : %s\n" "Memory" "$(free -h | awk '/^Mem/{print $3" / "$2}')"
    printf "  %-10s : %s\n" "Disk"   "$(df -h / | awk 'NR==2{print $3" / "$2}')"
    printf "  %-10s : %s\n" "IP"     "$(curl -s https://ipinfo.io/ip)"
    echo ""
}

help-me() {
    echo ""
    echo "  ┌─────────────────────────────────────┐"
    echo "  │         AVAILABLE COMMANDS          │"
    echo "  ├─────────────────────────────────────┤"
    echo "  │  ll          → detailed list        │"
    echo "  │  lt          → tree view            │"
    echo "  │  ..  / ...   → go up dirs           │"
    echo "  │  mkcd <dir>  → make & enter dir     │"
    echo "  │  serve [port]→ python http server   │"
    echo "  │  myip        → show public ip       │"
    echo "  │  ports       → show open ports      │"
    echo "  │  sysinfo     → system stats         │"
    echo "  │  projects    → go to ~/projects     │"
    echo "  │  reload      → reload shell         │"
    echo "  │  cls         → clear screen         │"
    echo "  │  q           → exit                 │"
    echo "  └─────────────────────────────────────┘"
    echo ""
}

# ── Banner ────────────────────────────────────────────────────────────────────
_banner() {
    clear
    echo ""
    echo -e "\033[01;32m  ╔══════════════════════════════════════╗"
    echo    "  ║       HackerTerm v2.1  ⚡            ║"
    echo    "  ╚══════════════════════════════════════╝"
    echo -e "\033[00;32m"
    printf "  %-10s : %s\n" "OS"     "$(lsb_release -d 2>/dev/null | cut -f2)"
    printf "  %-10s : %s\n" "Kernel" "$(uname -r)"
    printf "  %-10s : %s\n" "Uptime" "$(uptime -p | sed 's/up //')"
    printf "  %-10s : %s\n" "Memory" "$(free -h | awk '/^Mem/{print $3" / "$2}')"
    printf "  %-10s : %s\n" "CPU"    "$(nproc) cores"
    echo ""
    echo -e "\033[00;36m  Type help-me for commands.\033[0m"
    echo ""
}

_banner
cd ~
BASHRC

# ── 7. Start Script ──────────────────────────────────────────────────────────
echo -e "${CYAN}[*] Creating start script...${RESET}"
cat > ~/start.sh <<'EOF'
#!/bin/bash
SESSION="main"

tmux has-session -t "$SESSION" 2>/dev/null || \
    tmux new-session -d -s "$SESSION" /bin/bash

ttyd \
    -p 7681 \
    -c "1:1" \
    -W \
    tmux attach-session -t "$SESSION"
EOF
chmod +x ~/start.sh

# ── 8. Systemd Service ───────────────────────────────────────────────────────
echo -e "${CYAN}[*] Setting up service...${RESET}"
cat > /etc/systemd/system/hackerterm.service <<EOF
[Unit]
Description=HackerTerm Web Terminal
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=$HOME/start.sh
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable hackerterm
systemctl start hackerterm

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BGREEN}  ✅ Done! HackerTerm is running.${RESET}"
echo -e "${GREEN}  🌐 Open : http://$(curl -s https://ipinfo.io/ip):7681${RESET}"
echo -e "${GREEN}  🔑 User : 1  |  Pass : 1${RESET}"
echo ""
