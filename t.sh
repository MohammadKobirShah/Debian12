#!/bin/bash

# =============================================================================
#   HackerTerm v2.3 | Tunnel Edition | Kobir Shah
# =============================================================================

GREEN='\033[00;32m'
BGREEN='\033[01;32m'
CYAN='\033[00;36m'
RESET='\033[0m'

echo -e "${BGREEN}[*] Starting HackerTerm Tunnel Setup...${RESET}"

# ── 1. System Packages ───────────────────────────────────────────────────────
echo -e "${CYAN}[*] Installing packages...${RESET}"
apt-get update -y
apt-get install -y \
    bash wget curl git python3 \
    neofetch tmux nano htop \
    tree zip unzip jq \
    nodejs npm \
    openssh-client openssh-server

# ── 2. SSH Server Setup ──────────────────────────────────────────────────────
echo -e "${CYAN}[*] Configuring SSH server...${RESET}"
mkdir -p /run/sshd ~/.ssh
chmod 700 ~/.ssh

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
echo "AllowUsers root" >> /etc/ssh/sshd_config

# Generate host keys if missing
ssh-keygen -A

# Set root password
echo "root:1" | chpasswd

# ── 3. TTYd Download ─────────────────────────────────────────────────────────
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

# ── 4. Tmate Download (Public URLs without IPv4) ─────────────────────────────
echo -e "${CYAN}[*] Downloading tmate...${RESET}"
wget -qO /tmp/tmate.tar.xz \
    https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz
tar -xf /tmp/tmate.tar.xz -C /tmp
mv /tmp/tmate-2.4.0-static-linux-amd64/tmate /usr/local/bin/tmate
chmod +x /usr/local/bin/tmate
rm -rf /tmp/tmate*

# ── 5. sshx Download (Collaborative Sharing) ─────────────────────────────────
echo -e "${CYAN}[*] Downloading sshx...${RESET}"
wget -qO /usr/local/bin/sshx \
    https://s3.amazonaws.com/sshx/sshx-x86_64-unknown-linux-musl
chmod +x /usr/local/bin/sshx

# ── 6. Directories ───────────────────────────────────────────────────────────
mkdir -p ~/projects ~/.logs

# ── 7. Tmux Config ───────────────────────────────────────────────────────────
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

# ── 8. Nano Config ───────────────────────────────────────────────────────────
cat > ~/.nanorc <<'EOF'
set autoindent
set linenumbers
set mouse
set tabsize 4
set tabstospaces
set constantshow
include "/usr/share/nano/*.nanorc"
EOF

# ── 9. Bashrc ────────────────────────────────────────────────────────────────
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
    echo    "  ║       HackerTerm v2.3  ⚡            ║"
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

# ── 10. WebSSH Server ────────────────────────────────────────────────────────
echo -e "${CYAN}[*] Setting up WebSSH server...${RESET}"
mkdir -p /opt/webssh/public

cat > /opt/webssh/package.json <<'EOF'
{
  "name": "webssh",
  "version": "1.0.0",
  "description": "Web-based SSH terminal with private key support",
  "main": "server.js",
  "scripts": { "start": "node server.js" },
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.7.5",
    "ssh2": "^1.15.0"
  }
}
EOF

cat > /opt/webssh/server.js <<'EOF'
const express = require('express');
const http = require('http');
const path = require('path');
const { Server } = require('socket.io');
const { Client } = require('ssh2');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(path.join(__dirname, 'public')));

io.on('connection', (socket) => {
    let sshClient = null;
    let sshStream = null;

    socket.on('ssh-connect', (config) => {
        if (!config.host || !config.username) {
            socket.emit('status', 'Error: Host and Username are required');
            return;
        }
        sshClient = new Client();
        sshClient.on('ready', () => {
            socket.emit('status', 'Authenticated');
            sshClient.shell({
                term: 'xterm-256color',
                cols: config.cols || 80,
                rows: config.rows || 24
            }, (err, stream) => {
                if (err) {
                    socket.emit('status', 'Shell error: ' + err.message);
                    return;
                }
                sshStream = stream;
                socket.emit('status', 'Connected');
                stream.on('data', (data) => socket.emit('data', data.toString('utf-8')));
                stream.stderr.on('data', (data) => socket.emit('data', data.toString('utf-8')));
                stream.on('close', () => {
                    socket.emit('status', 'Disconnected');
                    socket.emit('data', '\r\n\n[Session closed]\r\n');
                    sshClient.end();
                });
                socket.on('data', (key) => { if (sshStream) sshStream.write(key); });
                socket.on('resize', ({ cols, rows }) => { if (sshStream) sshStream.setWindow(rows, cols, 0, 0); });
            });
        });
        sshClient.on('error', (err) => socket.emit('status', 'Error: ' + err.message));
        sshClient.on('end', () => socket.emit('status', 'Connection ended'));
        sshClient.on('close', () => socket.emit('status', 'Connection closed'));

        const connConfig = {
            host: config.host,
            port: config.port || 22,
            username: config.username,
            readyTimeout: 20000,
            keepaliveInterval: 10000,
            keepaliveCountMax: 3
        };
        if (config.privateKey && config.privateKey.trim().length > 0) {
            connConfig.privateKey = config.privateKey;
            if (config.passphrase) connConfig.passphrase = config.passphrase;
        } else if (config.password) {
            connConfig.password = config.password;
        }
        socket.emit('status', 'Connecting...');
        sshClient.connect(connConfig);
    });

    socket.on('disconnect', () => {
        if (sshStream) { sshStream.close(); sshStream = null; }
        if (sshClient) { sshClient.end(); sshClient = null; }
    });
});

const PORT = process.env.WEBSSH_PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`[WebSSH] Server running on http://0.0.0.0:${PORT}`);
});
EOF

cat > /opt/webssh/public/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebSSH — HackerTerm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/xterm@5.3.0/css/xterm.css" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #000; color: #0f0; font-family: 'Courier New', Courier, monospace; height: 100vh; overflow: hidden; }
        #login { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; gap: 12px; padding: 20px; }
        #login h1 { font-size: 2.2rem; margin-bottom: 10px; text-shadow: 0 0 10px #0f0; letter-spacing: 2px; }
        #login .subtitle { color: #080; margin-bottom: 20px; font-size: 0.9rem; }
        .form-group { display: flex; flex-direction: column; width: 420px; max-width: 95%; }
        label { font-size: 0.85rem; margin-bottom: 4px; color: #0c0; }
        input, textarea, button { background: #0a0a0a; border: 1px solid #0f0; color: #0f0; padding: 10px; font-family: inherit; font-size: 0.95rem; border-radius: 2px; }
        input:focus, textarea:focus { outline: none; box-shadow: 0 0 10px #0f0; }
        textarea { min-height: 140px; resize: vertical; }
        button { cursor: pointer; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; transition: all 0.2s; }
        button:hover { background: #0f0; color: #000; box-shadow: 0 0 15px #0f0; }
        .row { display: flex; gap: 10px; }
        .row .form-group { flex: 1; }
        .toggle-row { flex-direction: row; align-items: center; gap: 8px; margin-top: 5px; }
        .toggle-row input[type="checkbox"] { width: 18px; height: 18px; accent-color: #0f0; cursor: pointer; }
        .toggle-row label { margin: 0; cursor: pointer; }
        .hint { font-size: 0.75rem; color: #080; margin-top: 4px; }
        #terminal { display: none; height: 100vh; width: 100vw; padding: 8px; }
        #status-bar { position: fixed; top: 0; left: 0; right: 0; background: #0a0a0a; border-bottom: 1px solid #0f0; padding: 6px 15px; font-size: 0.8rem; display: none; justify-content: space-between; align-items: center; z-index: 100; }
        #status-bar .status-text { color: #0f0; }
        #status-bar .status-badge { background: #0f0; color: #000; padding: 2px 8px; font-weight: bold; font-size: 0.75rem; border-radius: 2px; }
        #back-btn { position: fixed; top: 35px; right: 10px; z-index: 101; display: none; background: #0a0a0a; border: 1px solid #0f0; color: #0f0; padding: 6px 12px; cursor: pointer; font-family: inherit; }
        #back-btn:hover { background: #0f0; color: #000; }
        .xterm-viewport { background: #000 !important; }
    </style>
</head>
<body>
    <div id="status-bar">
        <span class="status-text" id="status-text">Ready</span>
        <span class="status-badge" id="status-badge">IDLE</span>
    </div>
    <button id="back-btn" onclick="goBack()">Disconnect</button>
    <div id="login">
        <h1>🔐 WebSSH Terminal</h1>
        <div class="subtitle">Connect to any SSH server from your browser</div>
        <div class="form-group">
            <label for="host">Host</label>
            <input type="text" id="host" placeholder="example.com or 192.168.1.10">
        </div>
        <div class="row">
            <div class="form-group">
                <label for="port">Port</label>
                <input type="number" id="port" value="22">
            </div>
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" placeholder="root">
            </div>
        </div>
        <div class="form-group toggle-row">
            <input type="checkbox" id="useKey" onchange="toggleAuth()">
            <label for="useKey">Use SSH Private Key</label>
        </div>
        <div class="form-group" id="passwordGroup">
            <label for="password">Password</label>
            <input type="password" id="password" placeholder="Enter password">
        </div>
        <div class="form-group" id="keyGroup" style="display:none">
            <label for="privateKey">Private Key (PEM / OpenSSH format)</label>
            <textarea id="privateKey" placeholder="-----BEGIN OPENSSH PRIVATE KEY-----&#10;...&#10;-----END OPENSSH PRIVATE KEY-----"></textarea>
            <div class="hint">Paste the full private key. Keys with passphrases are supported.</div>
            <label for="passphrase" style="margin-top:10px">Key Passphrase (optional)</label>
            <input type="password" id="passphrase" placeholder="Leave empty if key has no passphrase">
        </div>
        <div class="form-group">
            <button onclick="connect()">Connect</button>
        </div>
    </div>
    <div id="terminal"></div>
    <script src="https://cdn.jsdelivr.net/npm/xterm@5.3.0/lib/xterm.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/xterm-addon-fit@0.8.0/lib/xterm-addon-fit.min.js"></script>
    <script src="/socket.io/socket.io.js"></script>
    <script>
        const socket = io();
        let term = null;
        let fitAddon = null;
        function toggleAuth() {
            const useKey = document.getElementById('useKey').checked;
            document.getElementById('passwordGroup').style.display = useKey ? 'none' : 'block';
            document.getElementById('keyGroup').style.display = useKey ? 'block' : 'none';
        }
        function setStatus(text, type = 'info') {
            const badge = document.getElementById('status-badge');
            const statusText = document.getElementById('status-text');
            statusText.textContent = text;
            badge.textContent = type.toUpperCase();
            badge.style.background = type === 'error' ? '#f00' : (type === 'success' ? '#0f0' : '#aa0');
            badge.style.color = type === 'success' ? '#000' : '#fff';
        }
        function connect() {
            const host = document.getElementById('host').value.trim();
            const port = parseInt(document.getElementById('port').value) || 22;
            const username = document.getElementById('username').value.trim();
            const useKey = document.getElementById('useKey').checked;
            if (!host || !username) { alert('Host and Username are required'); return; }
            const config = { host, port, username };
            if (useKey) {
                const key = document.getElementById('privateKey').value;
                if (!key.trim()) { alert('Please paste your private key'); return; }
                config.privateKey = key;
                const phrase = document.getElementById('passphrase').value;
                if (phrase) config.passphrase = phrase;
            } else {
                config.password = document.getElementById('password').value;
            }
            document.getElementById('login').style.display = 'none';
            document.getElementById('terminal').style.display = 'block';
            document.getElementById('status-bar').style.display = 'flex';
            document.getElementById('back-btn').style.display = 'block';
            setStatus('Initializing terminal...', 'info');
            initTerminal(config);
            socket.emit('ssh-connect', config);
        }
        function initTerminal(config) {
            term = new Terminal({
                fontFamily: '"Courier New", "DejaVu Sans Mono", monospace',
                fontSize: 14,
                theme: {
                    background: '#000000', foreground: '#00ff00', cursor: '#00ff00',
                    selectionBackground: '#003300', black: '#000000', red: '#ff0000',
                    green: '#00ff00', yellow: '#ffff00', blue: '#0000ff', magenta: '#ff00ff',
                    cyan: '#00ffff', white: '#ffffff', brightBlack: '#555555', brightRed: '#ff5555',
                    brightGreen: '#55ff55', brightYellow: '#ffff55', brightBlue: '#5555ff',
                    brightMagenta: '#ff55ff', brightCyan: '#55ffff', brightWhite: '#ffffff'
                },
                cursorBlink: true, scrollback: 50000, allowProposedApi: true
            });
            fitAddon = new FitAddon.FitAddon();
            term.loadAddon(fitAddon);
            term.open(document.getElementById('terminal'));
            setTimeout(() => { fitAddon.fit(); config.cols = term.cols; config.rows = term.rows; }, 100);
            term.onData(data => socket.emit('data', data));
            window.addEventListener('resize', () => { if (fitAddon) { fitAddon.fit(); socket.emit('resize', { cols: term.cols, rows: term.rows }); } });
        }
        function goBack() {
            if (term) { term.dispose(); term = null; }
            socket.disconnect();
            location.reload();
        }
        socket.on('data', data => { if (term) term.write(data); });
        socket.on('status', msg => {
            const lower = msg.toLowerCase();
            let type = 'info';
            if (lower.includes('error')) type = 'error';
            else if (lower.includes('connected')) type = 'success';
            else if (lower.includes('authenticated')) type = 'success';
            setStatus(msg, type);
        });
        socket.on('disconnect', () => {
            setStatus('Disconnected', 'error');
            if (term) term.writeln('\r\n\n[Connection lost]');
        });
    </script>
</body>
</html>
HTMLEOF

cd /opt/webssh && npm install

# ── 11. Start Script ─────────────────────────────────────────────────────────
echo -e "${CYAN}[*] Creating start script...${RESET}"
cat > ~/start.sh <<'EOF'
#!/bin/bash
SESSION="main"

tmux has-session -t "$SESSION" 2>/dev/null || \
    tmux new-session -d -s "$SESSION" /bin/bash

# Start SSH daemon
/usr/sbin/sshd

# Start WebSSH
cd /opt/webssh && node server.js >> ~/.logs/webssh.log 2>&1 &

# ── Tmate Public Tunnel (No IPv4 needed!) ────────────────────────────────────
(
    sleep 5
    TMATE_SOCK=/tmp/tmate.sock
    tmate -S "$TMATE_SOCK" new-session -d -s tmate -n public bash
    tmate -S "$TMATE_SOCK" wait tmate-ready
    echo "" >> ~/.logs/startup.log
    echo "$(date '+%Y-%m-%d %H:%M:%S') ═══ TMATE PUBLIC URLS ═══" >> ~/.logs/startup.log
    echo "SSH:  $(tmate -S "$TMATE_SOCK" display -p '#{tmate_ssh}')" >> ~/.logs/startup.log
    echo "WEB:  $(tmate -S "$TMATE_SOCK" display -p '#{tmate_web}')" >> ~/.logs/startup.log
    echo "READ: $(tmate -S "$TMATE_SOCK" display -p '#{tmate_ssh_ro}')" >> ~/.logs/startup.log
    echo "═══════════════════════════════════════" >> ~/.logs/startup.log
) &

# ── sshx Collaborative Session ───────────────────────────────────────────────
(
    sleep 8
    echo "" >> ~/.logs/startup.log
    echo "$(date '+%Y-%m-%d %H:%M:%S') ═══ SSHX COLLAB URL ═══" >> ~/.logs/startup.log
    sshx --quiet >> ~/.logs/sshx.log 2>&1 &
    sleep 3
    cat ~/.logs/sshx.log >> ~/.logs/startup.log
    echo "═══════════════════════════════════════" >> ~/.logs/startup.log
) &

# Start ttyd
ttyd \
    -p 7681 \
    -c "1:1" \
    -W \
    tmux attach-session -t "$SESSION"
EOF
chmod +x ~/start.sh

# ── 12. Systemd Services ─────────────────────────────────────────────────────
echo -e "${CYAN}[*] Setting up services...${RESET}"

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

cat > /etc/systemd/system/webssh.service <<EOF
[Unit]
Description=WebSSH Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/webssh
ExecStart=/usr/bin/node /opt/webssh/server.js
Restart=always
RestartSec=3
Environment=WEBSSH_PORT=3000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ssh hackerterm webssh
systemctl start ssh hackerterm webssh

# ── Done ─────────────────────────────────────────────────────────────────────
IP=$(curl -s https://ipinfo.io/ip)
echo ""
echo -e "${BGREEN}  ✅ Done! HackerTerm Tunnel Edition is ready.${RESET}"
echo -e "${GREEN}  🖥️  SSH Access : ssh root@${IP}${RESET}"
echo -e "${GREEN}  🔑 SSH Pass   : 1${RESET}"
echo -e "${GREEN}  🌐 HackerTerm : http://${IP}:7681${RESET}"
echo -e "${GREEN}  🔐 WebSSH     : http://${IP}:3000${RESET}"
echo ""
echo -e "${CYAN}  ⏳ Waiting for public tunnel URLs...${RESET}"
echo -e "${CYAN}  Run: tail -f ~/.logs/startup.log${RESET}"
echo ""
