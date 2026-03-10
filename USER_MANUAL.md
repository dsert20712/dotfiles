# Dotfiles User Manual

A reference guide for all tools, aliases, commands, and keybindings available after launching the Docker container.

---

## Table of Contents

1. [Tools Overview](#tools-overview)
2. [Shell Aliases](#shell-aliases)
3. [Shell Functions](#shell-functions)
4. [Keymaps & Keybindings](#keymaps--keybindings)
5. [Neovim](#neovim)
6. [Tmux](#tmux)
7. [Zellij](#zellij)
8. [Yazi (File Manager)](#yazi-file-manager)
9. [Theme & Appearance](#theme--appearance)

---

## Tools Overview

| Category | Tool | Purpose |
|---|---|---|
| **Shell** | zsh | Primary shell |
| **Shell** | nushell (`nu`) | Alternative modern shell |
| **Prompt** | starship | Shell prompt |
| **Multiplexer** | tmux | Terminal multiplexer |
| **Multiplexer** | zellij | Rust-based multiplexer |
| **Editor** | neovim (`nvim`) | Primary editor (LazyVim) |
| **Terminal** | wezterm | GPU-accelerated terminal |
| **Terminal** | ghostty | Fast terminal |
| **File Manager** | yazi | Terminal file manager |
| **Git TUI** | lazygit | Interactive git client |
| **Git Worktrees** | wt (worktrunk) | Git worktree manager |
| **GitHub TUI** | gh-dash | GitHub dashboard |
| **History** | atuin | Shell history with search |
| **Version Mgr** | mise | Runtime version manager |
| **Dir Jump** | zoxide (`z`) | Smart `cd` replacement |
| **Fuzzy Find** | fzf | Fuzzy finder |
| **File Find** | fd | Fast `find` replacement |
| **Search** | ripgrep (`rg`) | Fast `grep` replacement |
| **Pager** | bat | `cat` with syntax highlighting |
| **ls** | eza | Modern `ls` replacement |
| **HTTP client** | xh | HTTPie-like HTTP client |
| **Completions** | carapace | Shell completion generator |
| **DB** | turso | SQLite edge database CLI |

---

## Shell Aliases

### Navigation

| Alias | Command |
|---|---|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |
| `......` | `cd ../../../../..` |
| `cx <dir>` | `cd <dir>` and list contents |

### File & Text

| Alias | Command |
|---|---|
| `l` | `eza -l --icons --git -a` |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `ltree` | `eza --tree --level=2 --icons --git` |
| `la` | `tree` |
| `cat` | `bat` (syntax-highlighted cat) |
| `cl` | `clear` |
| `v` | `nvim` |
| `http` | `xh` |
| `rr` | `ranger` |

### Git

| Alias | Command |
|---|---|
| `gst` | `git status` |
| `ga` | `git add -p` (interactive patch) |
| `gadd` | `git add` |
| `gc "msg"` | `git commit -m` |
| `gca "msg"` | `git commit -a -m` |
| `gp` | `git push origin HEAD` |
| `gpu` | `git pull origin` |
| `gco` | `git checkout` |
| `gcoall` | `git checkout -- .` (discard all changes) |
| `gb` | `git branch` |
| `gba` | `git branch -a` |
| `gr` | `git remote` |
| `gre` | `git reset` |
| `gdiff` | `git diff` |
| `glog` | Pretty graph log |

### Docker

| Alias | Command |
|---|---|
| `dco` | `docker compose` |
| `dps` | `docker ps` |
| `dpa` | `docker ps -a` |
| `dl` | `docker ps -l -q` (last container ID) |
| `dx` | `docker exec -it` |

### Kubernetes

| Alias | Command |
|---|---|
| `k` | `kubectl` |
| `ka` | `kubectl apply -f` |
| `kg` | `kubectl get` |
| `kd` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kl` | `kubectl logs` |
| `kgpo` | `kubectl get pod` |
| `kgd` | `kubectl get deployments` |
| `ke` | `kubectl exec -it` |
| `kc` | `kubectx` (switch context) |
| `kns` | `kubens` (switch namespace) |
| `kcns` | `kubectl config set-context --current --namespace` |

### Security / Recon

| Alias | Command |
|---|---|
| `nm` | `nmap -sC -sV -oN nmap` |
| `server` | `python -m http.server 4445` |
| `tunnel` | `ngrok http 4445` |
| `fuzz` | `ffuf -w ~/hacking/SecLists/content_discovery_all.txt -mc all -u` |
| `gobust` | `gobuster dir ...` |

### Nushell-only

| Alias | Command |
|---|---|
| `asr` | `atuin scripts run` |

---

## Shell Functions

| Function | Description |
|---|---|
| `cx <dir>` | `cd` into directory then list contents |
| `fcd` | fzf-select a directory and cd into it |
| `f` | fzf-select a file and copy path to clipboard |
| `fv` | fzf-select a file and open in nvim |
| `ranger` | ranger that changes directory on exit |

---

## Keymaps & Keybindings

### Zsh

| Key | Action |
|---|---|
| `Ctrl+W` | Execute autosuggestion |
| `Ctrl+E` | Accept autosuggestion |
| `Ctrl+U` | Toggle autosuggestion |
| `Ctrl+L` | vi forward-word |
| `Ctrl+K` | History search up |
| `Ctrl+J` | History search down |
| `jj` | Enter vi command mode |
| `Ctrl+R` | Atuin history search |

### Nushell

| Key | Action |
|---|---|
| `Tab` | Completion menu |
| `Ctrl+N` | IDE-style completion |
| `Ctrl+R` | History search (Atuin) |
| `F1` | Help menu |
| `Ctrl+C` | Cancel |
| `Ctrl+D` | Quit shell |
| `Ctrl+L` | Clear screen |
| `Ctrl+A` | Start of line |
| `Ctrl+E` | End of line |
| `Ctrl+W` | Delete word backward |
| `Ctrl+K` | Cut to end of line |
| `Ctrl+U` | Cut from start of line |

---

## Neovim

LazyVim-based config. Leader key is `<Space>` (LazyVim default).

### Custom Keymaps

| Mode | Key | Action |
|---|---|---|
| Insert | `jj` | Exit to Normal mode |
| Insert | `jk` | Exit to Normal mode |

### Plugins Configured

| Plugin | Purpose |
|---|---|
| `conform.nvim` | Code formatting |
| Go plugin | Go language support |
| opencode | AI code assistant |
| `nvim-surround` | Surround text objects |
| windsurf | AI completion |
| LazyVim extras | Various LSP/language support |

> For full LazyVim keymaps see: https://www.lazyvim.org/keymaps

---

## Tmux

**Prefix:** `Ctrl+A`
**Mode:** vi keys

### Panes

| Key | Action |
|---|---|
| `prefix + |` | Split vertical |
| `prefix + -` | Split horizontal |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + x` | Kill pane |
| `prefix + z` | Zoom/fullscreen pane |

### Windows / Tabs

| Key | Action |
|---|---|
| `prefix + c` | New window |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + 1-9` | Go to window number |
| `prefix + ,` | Rename window |
| `prefix + &` | Kill window |

### Sessions

| Key | Action |
|---|---|
| `prefix + $` | Rename session |
| `prefix + d` | Detach session |
| `prefix + s` | List sessions |
| `prefix + O` | SessionX (session manager) |

### Copy Mode (vi)

| Key | Action |
|---|---|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank selection |
| `q` | Exit copy mode |

### Plugins

| Plugin | Purpose |
|---|---|
| tmux-sensible | Sane defaults |
| tmux-yank | System clipboard yank |
| tmux-resurrect | Save/restore sessions |
| tmux-continuum | Auto-save sessions |
| tmux-thumbs | Pick links/text with hints |
| tmux-fzf | Fuzzy find in tmux |
| tmux-fzf-url | Open URLs with fzf |
| tmux-sessionx | Session manager UI |
| tmux-floax | Floating pane overlay |
| catppuccin-tmux | Catppuccin Mocha theme |

---

## Zellij

### Mode Switching

| Key | Mode |
|---|---|
| `Ctrl+A` | Pane mode |
| `Ctrl+T` | Tab mode |
| `Ctrl+N` | Resize mode |
| `Ctrl+S` | Scroll mode |
| `Ctrl+X` | Session mode |
| `Ctrl+B` | Tmux-compat mode |
| `Ctrl+G` | Lock mode |
| `Esc` / `Enter` | Return to Normal |

### Normal Mode

| Key | Action |
|---|---|
| `Alt+H/L/J/K` | Move focus between panes |
| `Alt+N` | New pane |
| `Alt+=` | Increase pane size |
| `Alt+-` | Decrease pane size |
| `Alt+[` / `Alt+]` | Previous/next layout |

### Pane Mode (`Ctrl+A`)

| Key | Action |
|---|---|
| `h/j/k/l` | Move focus |
| `n` | New pane |
| `d` | New pane down |
| `x` | Close pane |
| `z` | Toggle fullscreen |
| `f` | Toggle pane frames |
| `w` | Toggle floating panes |
| `e` | Embed/float toggle |
| `r` | Rename pane |

### Tab Mode (`Ctrl+T`)

| Key | Action |
|---|---|
| `h/k` or `Left/Up` | Previous tab |
| `l/j` or `Right/Down` | Next tab |
| `n` | New tab |
| `x` | Close tab |
| `1-9` | Go to tab number |
| `a` | Toggle active tab sync |

### Resize Mode (`Ctrl+N`)

| Key | Action |
|---|---|
| `h/j/k/l` | Increase in direction |
| `H/J/K/L` | Decrease in direction |
| `=` / `+` | Increase all |
| `-` | Decrease all |

### Scroll Mode (`Ctrl+S`)

| Key | Action |
|---|---|
| `j/k` or `Down/Up` | Scroll |
| `Ctrl+F` / `Ctrl+B` | Page down/up |
| `d/u` | Half page down/up |
| `/` | Search down |
| `?` | Search up |
| `n/p` | Next/prev search result |
| `e` | Edit scrollback in editor |

---

## Yazi (File Manager)

Launch with: `yazi` (or `y` from shell after setup)

### Navigation

| Key | Action |
|---|---|
| `j/k` | Move cursor down/up |
| `J/K` | Move 5 lines down/up |
| `h` | Go to parent directory |
| `l` | Enter directory / open file |
| `H` | Previous directory (history) |
| `L` | Forward directory (history) |
| `gg` | Jump to top |
| `G` | Jump to bottom |
| `<Space>` | Toggle selection |

### File Operations

| Key | Action |
|---|---|
| `o` | Open file(s) |
| `y` | Copy |
| `x` | Cut |
| `p` | Paste |
| `P` | Paste (overwrite) |
| `d` | Move to trash |
| `D` | Permanently delete |
| `a` | Create file or directory |
| `r` | Rename |
| `.` | Toggle hidden files |

### Search & Jump

| Key | Action |
|---|---|
| `s` | Search by name (fd) |
| `S` | Search by content (rg) |
| `z` | Jump with zoxide |
| `Z` | Jump with fzf |
| `/` | Find next |
| `?` | Find previous |

### Tabs

| Key | Action |
|---|---|
| `t` | New tab |
| `[` / `]` | Previous/next tab |
| `{` / `}` | Swap with previous/next tab |
| `1-9` | Switch to tab number |

---

## Theme & Appearance

- **Color scheme:** Catppuccin Mocha (applied to Neovim, Tmux, Wezterm, Ghostty, Zellij, Lazygit, bat)
- **Font:** JetBrainsMono Nerd Font (with icons support)
- **Prompt:** Starship — shows git status, k8s context, AWS, Go, Docker, language versions
- **Prompt vi indicator:** `N` in normal mode, `>` in insert mode

---

## Quick Reference Card

```
Navigation        Files             Git               Multiplexer (Tmux)
----------        -----             ---               ------------------
z <dir>           l (eza list)      gst               prefix = Ctrl+A
cx <dir>          lt (tree view)    ga (add -p)       prefix+| split V
fcd (fzf cd)      cat (bat)         gc "msg"          prefix+- split H
.. / ... / ....   yazi (TUI fm)     gp (push HEAD)    prefix+z zoom
                  fv (fzf+nvim)     glog (pretty)     prefix+O sessions
                                    lazygit (TUI)
```
