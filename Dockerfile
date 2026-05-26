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

# ── Tmux Hacker Theme ─────────────────────────────────────────────────────────
RUN cat > /root/.tmux.conf <<'EOF'
set -g default-terminal "screen-256color"
set -g status-style "bg=black,fg=green"
set -g status-left "#[fg=green,bold] ⚡ [#S] "
set -g status-right "#[fg=green,bold] %H:%M  %d-%b-%Y "
set -g status-left-length 40
set -g status-right-length 40
set -g status-justify centre
setw -g window-status-style "fg=green,bg=black"
setw -g window-status-current-style "fg=black,bg=green,bold"
setw -g window-status-format " #I:#W "
setw -g window-status-current-format " #I:#W "
set -g pane-border-style "fg=green"
set -g pane-active-border-style "fg=green,bold"
set -g message-style "bg=black,fg=green,bold"
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
EOF

# ── Bashrc ────────────────────────────────────────────────────────────────────
RUN mkdir -p /root/.sessions

RUN cat > /root/.bashrc <<'BASHRC'

# ── History ──────────────────────────────────────────────────────────────────
export HISTFILE=/root/.bash_history
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"

# ── Hacker Green Terminal Colors ──────────────────────────────────────────────
printf '\033]11;#000000\007'
printf '\033]10;#00ff00\007'

# ── Git Branch in Prompt ──────────────────────────────────────────────────────
parse_git_branch() {
    git branch 2>/dev/null | grep '\*' | sed 's/\* //'
}

export PS1='\[\033[00;32m\]┌[\[\033[01;32m\]\u@\h\[\033[00;32m\]]-[\[\033[01;32m\]\w\[\033[00;32m\]]\[\033[01;33m\]$(b=$(parse_git_branch); [ -n "$b" ] && echo " ($b)")\[\033[00;32m\]\n└─▶ \[\033[0m\]'

# ── Aliases ───────────────────────────────────────────────────────────────────
export LS_COLORS='di=01;32:fi=00;32:ln=01;36:ex=01;32:'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias cls='clear'

# ── Help Command ──────────────────────────────────────────────────────────────
help-me() {
    echo -e "\033[01;32m"
    echo "  ┌─────────────────────────────────────────────────┐"
    echo "  │           ⚡  QUICK REFERENCE  ⚡               │"
    echo "  ├─────────────────────────────────────────────────┤"
    echo "  │  tmux new -s name      → new session            │"
    echo "  │  tmux ls               → list sessions          │"
    echo "  │  tmux attach -t name   → attach session         │"
    echo "  │  Ctrl+B then D         → detach from tmux       │"
    echo "  │  Ctrl+B then %         → split vertical         │"
    echo "  │  Ctrl+B then -         → split horizontal       │"
    echo "  │  Ctrl+B then Arrow     → move between panes     │"
    echo "  ├─────────────────────────────────────────────────┤"
    echo "  │  nano / vim            → text editors           │"
    echo "  │  python3 / node        → interpreters           │"
    echo "  │  git clone / pull      → git commands           │"
    echo "  └─────────────────────────────────────────────────┘"
    echo -e "\033[0m"
}

# ── Premium Hacker TUI Welcome ────────────────────────────────────────────────
clear
printf '\033[40m\033[2J\033[H'
echo -e "\033[01;32m"

echo "  ╔══════════════════════════════════════════════════════════════════╗"
echo "  ║                                                                  ║"
echo "  ║   ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗              ║"
echo "  ║   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗             ║"
echo "  ║   ███████║███████║██║     █████╔╝ █████╗  ██████╔╝             ║"
echo "  ║   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗             ║"
echo "  ║   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║             ║"
echo "  ║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝             ║"
echo "  ║                                                                  ║"
echo "  ║   ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗╗   ║"
echo "  ║      ██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██║   ║"
echo "  ║      ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║   ║"
echo "  ║      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║   ║"
echo "  ║      ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║   ║"
echo "  ║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ║"
echo "  ║                                                                  ║"
echo "  ╠══════════════════════════════════════════════════════════════════╣"
echo "  ║                                                                  ║"
printf "  \033[01;32m║\033[0m  \033[00;32m  ⚡  Node.js  : \033[01;32m%-10s\033[00;32m                                  \033[01;32m║\033[0m\n" "$(node --version 2>/dev/null || echo 'N/A')"
printf "  \033[01;32m║\033[0m  \033[00;32m  🐍  Python3  : \033[01;32m%-10s\033[00;32m                                  \033[01;32m║\033[0m\n" "$(python3 --version 2>/dev/null | awk '{print $2}' || echo 'N/A')"
printf "  \033[01;32m║\033[0m  \033[00;32m  🌿  Git      : \033[01;32m%-10s\033[00;32m                                  \033[01;32m║\033[0m\n" "$(git --version 2>/dev/null | awk '{print $3}' || echo 'N/A')"
printf "  \033[01;32m║\033[0m  \033[00;32m  📦  NPM      : \033[01;32m%-10s\033[00;32m                                  \033[01;32m║\033[0m\n" "$(npm --version 2>/dev/null || echo 'N/A')"
echo "  ║                                                                  ║"
echo "  ╠══════════════════════════════════════════════════════════════════╣"
echo "  ║                                                                  ║"
echo "  ║   💻  Type  [ help-me ]  for quick command reference            ║"
echo "  ║   🔒  Session is persistent — safe to close browser             ║"
echo "  ║                                                                  ║"
echo "  ╠══════════════════════════════════════════════════════════════════╣"
echo "  ║                                                                  ║"
echo "  ║        Developed with 💚 by  ░░ Kobir Shah ░░                   ║"
echo "  ║        GitHub : github.com/MohammadKobirShah                            ║"
echo "  ║                                                                  ║"
echo "  ╚══════════════════════════════════════════════════════════════════╝"
echo -e "\033[0m"

cd /root
BASHRC

# ── Entrypoint ────────────────────────────────────────────────────────────────
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
