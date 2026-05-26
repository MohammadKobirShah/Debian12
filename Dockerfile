FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=7681 \
    USERNAME=1 \
    PASSWORD=1

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
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# Hacker green on black theme for tmux
RUN cat > /root/.tmux.conf <<'EOF'
set -g default-terminal "screen-256color"

# Status bar - hacker green theme
set -g status-style "bg=black,fg=green"
set -g status-left "#[fg=green,bold][#S] "
set -g status-right "#[fg=green,bold]%H:%M %d-%b"
set -g status-left-length 30

# Window titles
setw -g window-status-style "fg=green,bg=black"
setw -g window-status-current-style "fg=black,bg=green,bold"

# Pane borders
set -g pane-border-style "fg=green"
set -g pane-active-border-style "fg=green,bold"

# Message style
set -g message-style "bg=black,fg=green,bold"

# Mouse support
set -g mouse on

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1
EOF

# Persistent bash history + hacker theme bashrc
RUN mkdir -p /root/.sessions

RUN cat >> /root/.bashrc <<'EOF'

# ── History ──────────────────────────────────────────────
export HISTFILE=/root/.bash_history
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# ── Hacker Green Theme ───────────────────────────────────
# Force terminal black background + green text
printf '\033]11;#000000\007'   # background black
printf '\033]10;#00ff00\007'   # foreground green

# Green bold prompt with git branch
parse_git_branch() {
    git branch 2>/dev/null | grep '*' | sed 's/* //'
}

export PS1='\[\033[00;32m\]┌[\[\033[01;32m\]\u@\h\[\033[00;32m\]]-[\[\033[01;32m\]\w\[\033[00;32m\]]$(b=$(parse_git_branch); [ -n "$b" ] && echo "-[\[\033[01;33m\]$b\[\033[00;32m\]]")\n\[\033[00;32m\]└─▶ \[\033[0m\]'

# ── Colors for ls, grep ──────────────────────────────────
export LS_COLORS='di=01;32:fi=00;32:ln=01;36:ex=01;32:'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'

# ── Welcome Banner ───────────────────────────────────────
clear

# Black background fill
printf '\033[40m\033[2J\033[H'

echo -e "\033[01;32m"
toilet -f bigmono9 --filter border "WELCOME" 2>/dev/null || \
figlet -f big "WELCOME" 2>/dev/null || \
echo "=== WELCOME ==="

echo -e "\033[01;32m"
toilet -f future "TO YOUR TERMINAL" 2>/dev/null || \
figlet "TO YOUR TERMINAL" 2>/dev/null || \
echo "=== TO YOUR TERMINAL ==="

echo -e "\033[00;32m"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  $(node --version 2>/dev/null | xargs printf '%-10s') Node.js is ready              ║"
echo "  ║  $(python3 --version 2>/dev/null | xargs printf '%-16s') is ready        ║"
echo "  ║  Type 'help-me' for quick command reference  ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "\033[0m"

cd /root
EOF

# Quick help command
RUN cat >> /root/.bashrc <<'EOF'

help-me() {
    echo -e "\033[01;32m"
    echo "  ┌─── QUICK REFERENCE ──────────────────────────┐"
    echo "  │  tmux new -s name    → new session            │"
    echo "  │  tmux ls             → list sessions          │"
    echo "  │  tmux attach -t name → attach session         │"
    echo "  │  Ctrl+B then D       → detach from tmux       │"
    echo "  │  Ctrl+B then %       → split vertical         │"
    echo "  │  Ctrl+B then "       → split horizontal       │"
    echo "  │  nano / vim          → text editors           │"
    echo "  │  python3 / node      → interpreters           │"
    echo "  └───────────────────────────────────────────────┘"
    echo -e "\033[0m"
}
EOF

# Entrypoint script
RUN cat > /start.sh <<'EOF'
#!/bin/bash

SESSION_NAME="main"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" /bin/bash
    echo "Started new tmux session: $SESSION_NAME"
else
    echo "Attaching to existing tmux session: $SESSION_NAME"
fi

exec ttyd \
    -p "${PORT}" \
    -c "${USERNAME}:${PASSWORD}" \
    -W \
    tmux attach-session -t "$SESSION_NAME"
EOF

RUN chmod +x /start.sh

EXPOSE 7681

CMD ["/start.sh"]
