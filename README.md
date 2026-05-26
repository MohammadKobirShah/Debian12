# 🏴‍☠️ Hacker TTYd — Persistent Web Terminal

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-x86_64-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

> A persistent web-based terminal powered by [ttyd](https://github.com/tsl0922/ttyd) + tmux. Sessions **never reset** on browser close. Runs 24/7 in the background.

---

## ⚡ Features

| Feature | Description |
|---|---|
| 🔴 **Never Resets** | Sessions persist even after browser/tab closes |
| 🌐 **Web Access** | Access terminal from any browser |
| 🎨 **Hacker Theme** | Green-on-black matrix aesthetic |
| 📜 **Persistent History** | Bash history survives reconnects |
| 🖥️ **tmux Sessions** | Multi-window, split panes, detach/reattach |
| 🛠️ **Dev Tools Ready** | Node.js, npm, Python3, git, nano, vim, figlet |

---

## 🚀 Quick Start

### 1. Build

```bash
git clone https://github.com/MohammadKobirShah/Debian12.git
cd Debian12
docker build -t Debian12 .
