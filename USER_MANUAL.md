# Dotfiles User Manual

Complete reference for the tools, aliases, keybindings, and workflows available after launching the Docker container.

> **Default shell:** Nushell (`nu`) — set as login shell. Tmux also starts `nu` by default.
> **Editor:** `$EDITOR` = `nvim`
> **Theme:** Catppuccin Mocha across all tools
> **Font:** JetBrainsMono Nerd Font

---

## Table of Contents

1. [First-Time Setup](#first-time-setup)
2. [Tools Reference](#tools-reference)
3. [Shell: Nushell](#shell-nushell)
4. [Shell: Zsh](#shell-zsh)
5. [Tmux](#tmux)
6. [Zellij](#zellij)
7. [Neovim](#neovim)
8. [Yazi — File Manager](#yazi--file-manager)
9. [Git Tooling](#git-tooling)
10. [CLI Utilities](#cli-utilities)
11. [Starship Prompt](#starship-prompt)
12. [Quick Reference Card](#quick-reference-card)

---

## First-Time Setup

After container start, if configs aren't symlinked yet:

```sh
cd ~/dotfiles
stow .           # symlinks everything into ~/.config and ~/ via GNU Stow
```

First launch Tmux — plugins are pre-installed at `/opt/tmux-plugins/`:

```
tmux
# Optionally verify plugins:
prefix + I       # (Ctrl+A then I) — should show "Already installed" for all plugins
```

First launch Neovim — LazyVim and all plugins install automatically:

```sh
nvim
```

---

## Tools Reference

All tools are installed to `/usr/local/bin` (system-wide) or `~/.local/bin` (user).

| Tool | Binary | Purpose |
|---|---|---|
| **Nushell** | `nu` | Default login shell. Structured data, modern syntax. |
| **Zsh** | `zsh` | Secondary shell. Available but not default in Docker. |
| **Starship** | `starship` | Cross-shell prompt. Minimal left, rich right side. |
| **Neovim** | `nvim` | Primary editor, configured with LazyVim framework. |
| **Tmux** | `tmux` | Terminal multiplexer. Prefix = `Ctrl+A`. |
| **Zellij** | `zellij` | Rust-based multiplexer, modal like vim. |
| **Yazi** | `yazi` | Terminal file manager with vim-style keys. |
| **Lazygit** | `lazygit` | Interactive TUI for git. Configured with delta pager. |
| **gh-dash** | `gh-dash` | GitHub PR/issue dashboard TUI. |
| **worktrunk** | `wt` | Git worktree manager — work on multiple branches simultaneously. |
| **Atuin** | `atuin` | Shell history search (replaces `Ctrl+R`). Compact style, syncs across sessions. |
| **zoxide** | `z` | Smart `cd` — learns your frequent directories. |
| **fzf** | `fzf` | Fuzzy finder. Default command uses `fd` to list files. |
| **eza** | `eza` | Modern `ls` with icons, git status, tree view. |
| **bat** | `bat` | `cat` replacement with syntax highlighting, line numbers, git diff. |
| **ripgrep** | `rg` | Extremely fast grep. Used by Neovim Telescope. |
| **fd** | `fd` | Fast `find` replacement. Respects `.gitignore`. |
| **carapace** | `carapace` | Shell completions generator, bridges zsh/fish/bash completions into Nushell. |
| **direnv** | `direnv` | Loads `.envrc` files automatically on `cd`. Hooked into Nushell pre-prompt. |
| **mise** | `mise` | Runtime version manager for Node, Python, Go, etc. (`~/.local/share/mise/shims`). |
| **Turso** | `turso` | SQLite edge database CLI. |
| **GitButler** | `but` | Git client focused on branch management. (May not be present in test mode.) |
| **Node.js** | `node` | v22, required for Neovim Mason/LSP servers. |
| **xh** | `xh` | HTTP client (HTTPie-compatible, faster). Aliased as `http`. |

---

## Shell: Nushell

Nushell (`nu`) is the **default shell**. It has structured data pipelines, vi edit mode, and completions via carapace.

### Edit Mode

Nushell runs in **vi mode** (`edit_mode: vi`). Cursor changes shape:
- Insert mode → block cursor (`:`)
- Normal mode → underscore cursor (`>`)

### Aliases

| Alias | Expands to | Notes |
|---|---|---|
| `l` | `ls --all` | List all including hidden |
| `ll` | `ls -l` | Long list |
| `lt` | `eza --tree --level=2 --long --icons --git` | Tree view with git status |
| `c` | `clear` | Clear screen |
| `v` | `nvim` | Open Neovim |
| `asr` | `atuin scripts run` | Run saved Atuin scripts |
| **Git** | | |
| `gst` | `git status` | |
| `ga` | `git add -p` | Interactive patch-mode staging |
| `gadd` | `git add` | Stage files |
| `gc` | `git commit -m` | Commit with message: `gc "msg"` |
| `gca` | `git commit -a -m` | Stage all tracked + commit |
| `gp` | `git push origin HEAD` | Push current branch |
| `gpu` | `git pull origin` | Pull from origin |
| `gco` | `git checkout` | |
| `gcoall` | `git checkout -- .` | Discard all unstaged changes |
| `gb` | `git branch` | List local branches |
| `gba` | `git branch -a` | List all branches |
| `gr` | `git remote` | List remotes |
| `gre` | `git reset` | |
| `gdiff` | `git diff` | |
| `glog` | `git log --graph ...` | Colorized graph log |

### Functions

| Function | Description |
|---|---|
| `cx <dir>` | `cd` into `<dir>` then list contents with `ls -l` |

### Keybindings

| Key | Action |
|---|---|
| `Tab` | Cycle through completions (columnar menu) |
| `Ctrl+N` | IDE-style completion popup (with descriptions) |
| `Ctrl+R` | Open Atuin history search UI |
| `F1` | Open help menu |
| `Ctrl+C` | Cancel command |
| `Ctrl+D` | Quit shell |
| `Ctrl+L` | Clear screen |
| `Ctrl+Q` | Search history inline |
| `Ctrl+O` | Open current command line in `$EDITOR` |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line (or accept history hint) |
| `Ctrl+Left` | Move one word left |
| `Ctrl+Right` | Move one word right (or accept history hint word) |
| `Alt+Backspace` | Delete one word backward |
| `Up` / `Down` | Navigate history or menu |
| `Right` | Accept history hint (full line) |
| `Home` / `End` | Start / end of line |
| `Shift+Tab` | Previous completion item |
| `Ctrl+X` | Next page in completion menu (emacs mode) |

### Automatic Hooks

- **direnv**: Loads `.envrc` automatically before every prompt (via `pre_prompt` hook)
- **Table display**: Wide terminals (≥100 cols) show expanded tables; narrow terminals show compact
- **Completions**: Carapace bridges completions from `zsh`, `fish`, `bash`, `inshellisense`

### PATH (Nushell)

```
~/.turso/
~/.local/share/mise/shims/    ← mise-managed runtimes (node, python, etc.)
~/.local/bin/
```

---

## Shell: Zsh

Zsh is available but **not the default** in Docker. It has macOS-specific paths from the original config (Homebrew, Nix, etc.) that won't apply.

### Aliases (Zsh — same git/docker/k8s as Nushell, plus:)

| Alias | Expands to |
|---|---|
| `la` | `tree` |
| `cat` | `bat` |
| `cl` | `clear` |
| `l` | `eza -l --icons --git -a` |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `ltree` | `eza --tree --level=2 --icons --git` |
| `v` | `nvim` |
| `http` | `xh` |
| `rr` | `ranger` |
| `nm` | `nmap -sC -sV -oN nmap` |
| `server` | `python -m http.server 4445` |
| `tunnel` | `ngrok http 4445` |
| `fuzz` | `ffuf -w ~/hacking/SecLists/content_discovery_all.txt -mc all -u` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |
| `......` | `cd ../../../../..` |
| **Docker** | |
| `dco` | `docker compose` |
| `dps` | `docker ps` |
| `dpa` | `docker ps -a` |
| `dl` | `docker ps -l -q` (last container ID) |
| `dx` | `docker exec -it` |
| **Kubernetes** | |
| `k` | `kubectl` |
| `ka` | `kubectl apply -f` |
| `kg` | `kubectl get` |
| `kd` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kl` | `kubectl logs -f` (note: streaming with `-f`) |
| `kgpo` | `kubectl get pod` |
| `kgd` | `kubectl get deployments` |
| `ke` | `kubectl exec -it` |
| `kc` | `kubectx` (switch context) |
| `kns` | `kubens` (switch namespace) |
| `kcns` | `kubectl config set-context --current --namespace` |

### Functions (Zsh)

| Function | Description |
|---|---|
| `cx <dir>` | `cd` then list contents |
| `fcd` | fzf-select a directory and `cd` into it |
| `f` | fzf-select a file, copy path to clipboard (macOS `pbcopy`) |
| `fv` | fzf-select a file and open in `nvim` |
| `ranger` | ranger file manager — changes shell CWD on quit via temp file |

### Keybindings (Zsh)

| Key | Action |
|---|---|
| `Ctrl+W` | Execute autosuggestion immediately |
| `Ctrl+E` | Accept autosuggestion (append to line) |
| `Ctrl+U` | Toggle autosuggestion on/off |
| `Ctrl+L` | vi forward-word |
| `Ctrl+K` | Search history upward |
| `Ctrl+J` | Search history downward |
| `jj` | Enter vi command mode (from insert mode) |
| `Ctrl+R` | Atuin history search |

### FZF Config (Zsh)

```
FZF_DEFAULT_COMMAND = fd --type f --hidden --follow
```
fzf finds all files including hidden, following symlinks.

---

## Tmux

**Prefix:** `Ctrl+A`
**Default shell:** `/usr/local/bin/nu` (Nushell)
**Copy mode:** vi keys
**Mouse:** enabled — scroll wheel scrolls pane buffer (enters copy mode), no arrow-key bleed into Atuin
**Status bar:** top, Catppuccin Mocha, shows session name (left) and current directory (right)

### Behavior Settings

| Setting | Value | Effect |
|---|---|---|
| `base-index` | 1 | Windows numbered from 1 |
| `detach-on-destroy` | off | Switching to next session instead of exiting when last window closes |
| `escape-time` | 0 | No delay after Escape — snappy vi mode |
| `history-limit` | 1,000,000 | Very large scrollback |
| `renumber-windows` | on | Gaps are filled automatically |
| `set-clipboard` | on | Integrates with system clipboard |
| `status-position` | top | Status bar at top |

### Keybindings

All bindings require the prefix (`Ctrl+A`) first unless noted as "global".

#### Sessions

| Binding | Action |
|---|---|
| `prefix + d` | Detach from session |
| `prefix + D` | Lock server |
| `prefix + S` | Choose session interactively |
| `prefix + o` | **SessionX** — fuzzy session manager (with zoxide integration) |
| `prefix + $` | *(standard)* Rename session |

#### Windows

| Binding | Action |
|---|---|
| `prefix + c` | New window (opens in `$HOME`) |
| `prefix + H` | Previous window |
| `prefix + L` | Next window |
| `prefix + ^A` | Last (previously active) window |
| `prefix + ^W` / `prefix + w` | List windows |
| `prefix + r` | Rename window |
| `prefix + R` | Reload tmux config |
| `prefix + "` | Choose window interactively |

#### Panes

| Binding | Action |
|---|---|
| `prefix + s` | Split pane **vertically** (new pane below, same path) |
| `prefix + v` | Split pane **horizontally** (new pane to the right, same path) |
| `prefix + \|` | Split window |
| `prefix + h` | Focus pane left |
| `prefix + j` | Focus pane down |
| `prefix + k` | Focus pane up |
| `prefix + l` | Focus pane right / refresh client |
| `prefix + z` | Zoom/unzoom current pane (fullscreen toggle) |
| `prefix + x` | Swap pane with next |
| `prefix + c` | Kill current pane |
| `prefix + P` | Toggle pane border status |
| `prefix + *` | Synchronize panes (broadcast keystrokes to all panes) |
| `prefix + ,` | Resize pane left 20 cells |
| `prefix + .` | Resize pane right 20 cells |
| `prefix + -` | Resize pane down 7 cells |
| `prefix + =` | Resize pane up 7 cells |
| `prefix + p` | **Floax** — toggle floating pane overlay (80% × 80%, magenta border) |
| `prefix + K` | Clear pane (sends `clear` + Enter) |
| `prefix + :` | Command prompt |

#### Copy Mode (vi)

| Binding | Action |
|---|---|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank selection to clipboard |
| `q` | Exit copy mode |

#### URL / Link Picker

| Binding | Action |
|---|---|
| `prefix + u` | **tmux-fzf-url** — pick and open URLs visible in pane (history limit: 2000) |
| `prefix + F` | **tmux-thumbs** — show hints over text/links for quick copy |

### Plugins

| Plugin | Purpose |
|---|---|
| **TPM** | Plugin manager — plugins pre-installed at `/opt/tmux-plugins/`. Update with `prefix + U`. |
| **tmux-sensible** | Sane defaults (longer history, faster response, etc.) |
| **tmux-yank** | System clipboard integration in copy mode |
| **tmux-resurrect** | Save (`prefix + Ctrl+S`) and restore (`prefix + Ctrl+R`) sessions across restarts. Saves Neovim sessions too. |
| **tmux-continuum** | Auto-save sessions periodically (restore is off by default) |
| **tmux-thumbs** | Regex-based hint mode for copying any text in the pane |
| **tmux-fzf** | fzf integration for windows, panes, commands |
| **tmux-fzf-url** | Collect and open URLs from pane history via fzf |
| **catppuccin-tmux** | Catppuccin Mocha theme for status bar |
| **tmux-sessionx** | Enhanced session manager with fzf + zoxide (`prefix + o`). Custom paths include `~/dotfiles`. |
| **tmux-floax** | Floating scratch pane (`prefix + p`). Path follows current pane automatically. |

---

## Zellij

Zellij is a modal multiplexer. It opens in **Normal mode**. Most actions require entering a specific mode first.

**Theme:** Catppuccin Mocha
**Pane frames:** disabled (cleaner look)
**On force close:** detach (keeps session running)
**Simplified UI:** true (no arrow font decorations)

### Mode Map

```
Normal ──────────────────────────────────────────────────┐
  Ctrl+A → Pane mode     Ctrl+T → Tab mode               │
  Ctrl+N → Resize mode   Ctrl+S → Scroll mode            │
  Ctrl+X → Session mode  Ctrl+B → Tmux compat mode       │
  Ctrl+G → Locked mode   Alt+r  → Rename Tab             │
  Enter/Esc → back to Normal (from any mode)             │
└───────────────────────────────────────────────────────-┘
```

### Global (Normal + all non-locked modes)

| Key | Action |
|---|---|
| `Ctrl+G` | Enter **Locked** mode (pass all keys through to app) |
| `Alt+N` | New pane (without entering Pane mode) |
| `Alt+H` / `Alt+Left` | Move focus left or to previous tab |
| `Alt+L` / `Alt+Right` | Move focus right or to next tab |
| `Alt+J` / `Alt+Down` | Move focus down |
| `Alt+K` / `Alt+Up` | Move focus up |
| `Alt+=` / `Alt++` | Increase pane size |
| `Alt+-` | Decrease pane size |
| `Alt+[` | Previous swap layout |
| `Alt+]` | Next swap layout |

### Pane Mode (`Ctrl+A`)

After entering pane mode, actions execute and return to Normal.

| Key | Action |
|---|---|
| `h/j/k/l` or arrows | Move focus in direction |
| `p` | Switch to next pane (cycle) |
| `n` | New pane (to the right) |
| `d` | New pane downward |
| `x` | Close focused pane |
| `z` | Toggle fullscreen for focused pane |
| `f` | Toggle pane frames (borders) on/off |
| `w` | Toggle floating panes |
| `Ctrl+A` | Toggle floating panes (same as `w`) |
| `e` | Toggle pane between embedded and floating |
| `r` | Rename pane |

### Tab Mode (`Ctrl+T`)

| Key | Action |
|---|---|
| `h/k` or `Left/Up` | Previous tab |
| `l/j` or `Right/Down` | Next tab |
| `n` | New tab |
| `x` | Close current tab |
| `s` | Toggle active sync tab (broadcast to all panes) |
| `b` | Break pane out to new tab |
| `[` | Break pane to previous tab |
| `]` | Break pane to next tab |
| `1`–`9` | Jump to tab number |
| `a` | Toggle tab |
| `r` | Rename tab |

### Resize Mode (`Ctrl+N`)

| Key | Action |
|---|---|
| `h/j/k/l` | Increase size in direction (left/down/up/right) |
| `H/J/K/L` | Decrease size in direction |
| `=` / `+` | Increase all (grow pane uniformly) |
| `-` | Decrease all |

### Scroll Mode (`Ctrl+S`)

| Key | Action |
|---|---|
| `j/k` or arrows | Scroll down/up |
| `Ctrl+F` / `PageDown` / `l` | Page down |
| `Ctrl+B` / `PageUp` / `h` | Page up |
| `d` | Half page down |
| `u` | Half page up |
| `G` | Scroll to bottom |
| `e` | Open scrollback in `$EDITOR` (Neovim) |
| `s` | Enter search mode (type to search) |

### Search Mode (from Scroll)

| Key | Action |
|---|---|
| `n` | Next match |
| `p` | Previous match |
| `c` | Toggle case sensitivity |
| `w` | Toggle wrap search |
| `o` | Toggle whole-word matching |
| `Ctrl+/` | Exit search, return to Normal |

### Session Mode (`Ctrl+X`)

| Key | Action |
|---|---|
| `d` | Detach from session |
| `w` | Open session manager (floating plugin) |
| `Ctrl+X` | Toggle between Session and Scroll mode |

### Tmux Compat Mode (`Ctrl+B`)

| Key | Action |
|---|---|
| `[` | Enter Scroll mode |
| `Ctrl+B` | Send literal `Ctrl+B` to terminal |
| `"` | New pane downward |
| `%` | New pane to the right |
| `z` | Toggle fullscreen |
| `c` | New tab |
| `,` | Rename tab |
| `p` / `n` | Previous / next tab |
| `h/j/k/l` or arrows | Move focus |
| `o` | Focus next pane |
| `d` | Detach |
| `Space` | Next swap layout |
| `x` | Close focused pane |

---

## Neovim

**Framework:** LazyVim (with `lazy.nvim` plugin manager)
**Leader key:** `<Space>` (LazyVim default)
**Line wrap:** enabled (`vim.opt.wrap = true`)

### Custom Keymaps

| Mode | Keys | Action |
|---|---|---|
| Insert | `jj` | Exit to Normal mode |
| Insert | `jk` | Exit to Normal mode |

### Plugin: opencode.nvim (AI assistant)

opencode is an AI coding assistant embedded in Neovim. All bindings use `<leader>o` prefix.

| Keys | Mode | Action |
|---|---|---|
| `<leader>ot` | Normal | Toggle opencode panel (embedded) |
| `<leader>oa` | Normal | Ask about code at cursor (`@cursor:`) |
| `<leader>oa` | Visual | Ask about selected code (`@selection:`) |
| `<leader>o+` | Normal | Add current buffer to prompt |
| `<leader>o+` | Visual | Add selection to prompt |
| `<leader>oe` | Normal | Explain code at cursor and its context |
| `<leader>on` | Normal | Start a new opencode session |
| `<leader>os` | Normal/Visual | Open prompt selector |
| `Shift+Ctrl+U` | Normal | Scroll opencode messages half page up |
| `Shift+Ctrl+D` | Normal | Scroll opencode messages half page down |

### Plugin: mini.surround

Surround text objects (add, delete, replace surrounding characters).

| Keys | Action | Example |
|---|---|---|
| `sa<motion><char>` | Add surrounding | `saiw"` → surround word with `"` |
| `sd<char>` | Delete surrounding | `sd"` → delete surrounding `"` |
| `gsr<old><new>` | Replace surrounding | `gsr"'` → change `"` to `'` |
| `gsf<char>` | Find surrounding (right) | |
| `gsF<char>` | Find surrounding (left) | |
| `gsh<char>` | Highlight surrounding | |
| `gsn` | Update `n_lines` search range | |

### Plugin: conform.nvim (Formatter)

Auto-formats on save. Custom config:

| File type | Formatter |
|---|---|
| YAML | `yamlfmt` with basic formatter and `indentless_arrays=true` (Kubernetes-friendly) |

### Plugin: Go (LSP via gopls)

`gopls` configured with:
- `unusedparams` analysis
- `staticcheck`
- `usePlaceholders`
- `completeUnimported` (auto-import)
- `gofumpt` formatting

### LazyVim Built-in Keymaps

LazyVim provides extensive default keymaps. Key ones:

| Keys | Action |
|---|---|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | Find buffers |
| `<leader>e` | File explorer (neo-tree) |
| `<leader>gg` | Open lazygit |
| `<leader>bd` | Delete buffer |
| `<leader>l` | Lazy plugin manager |
| `<leader>cm` | Mason LSP installer |
| `gcc` | Toggle line comment |
| `gc<motion>` | Toggle comment |
| `]d` / `[d` | Next/prev diagnostic |
| `<leader>cd` | Show line diagnostic |
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gr` | References |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |

> Full list: https://www.lazyvim.org/keymaps

---

## Yazi — File Manager

Launch: `yazi`

Three-pane layout: parent directory | current directory | preview. Vim-style navigation.

### Navigation

| Key | Action |
|---|---|
| `j` / `k` | Move cursor down / up |
| `J` / `K` | Move cursor down / up 5 lines |
| `Ctrl+D` / `Ctrl+U` | Move cursor half page down / up |
| `Ctrl+F` / `Ctrl+B` | Move cursor one full page down / up |
| `h` | Go to parent directory |
| `l` | Enter directory / open file |
| `H` | Go back in history |
| `L` | Go forward in history |
| `gg` | Jump to top |
| `G` | Jump to bottom |
| `Esc` | Clear selection, exit visual mode, or cancel search |
| `q` | Quit (writes CWD to shell) |
| `Q` | Quit without writing CWD |
| `Ctrl+C` | Close current tab or quit if last tab |
| `Ctrl+Z` | Suspend process |

### Selection

| Key | Action |
|---|---|
| `<Space>` | Toggle selection on hovered file, advance cursor |
| `v` | Enter visual mode (selection mode) |
| `V` | Enter visual unset mode |
| `Ctrl+A` | Select all files |
| `Ctrl+R` | Invert selection |

### File Operations

| Key | Action |
|---|---|
| `o` / `<Enter>` | Open selected files |
| `O` | Open interactively (choose application) |
| `y` | Copy (yank) selected files |
| `x` | Cut selected files |
| `p` | Paste yanked files |
| `P` | Paste (overwrite existing) |
| `-` | Symlink (absolute path) |
| `_` | Symlink (relative path) |
| `d` | Move to trash |
| `D` | Permanently delete |
| `a` | Create file or directory (trailing `/` = directory) |
| `r` | Rename (cursor positioned before extension) |
| `;` | Run a shell command |
| `:` | Run a shell command (blocking — wait for it to finish) |
| `.` | Toggle hidden files visibility |

### Search & Jump

| Key | Action |
|---|---|
| `s` | Search files by name using `fd` |
| `S` | Search files by content using `rg` |
| `Ctrl+S` | Cancel ongoing search |
| `f` | Filter files in current directory (smart case) |
| `/` | Find next (by name, smart case) |
| `?` | Find previous |
| `n` | Go to next found item |
| `N` | Go to previous found item |
| `z` | Jump to directory using **zoxide** |
| `Z` | Jump to directory or reveal file using **fzf** |

### Tabs

| Key | Action |
|---|---|
| `t` | New tab (opens at current directory) |
| `[` / `]` | Previous / next tab |
| `{` / `}` | Swap current tab with previous / next |
| `1`–`9` | Switch to tab number |

### Goto Shortcuts (chord: `g`)

| Keys | Action |
|---|---|
| `gh` | Go to home directory (`~`) |
| `gc` | Go to `~/.config` |
| `gd` | Go to `~/Downloads` |
| `g<Space>` | Go to directory interactively |

### Copy to Clipboard (chord: `c`)

| Keys | Action |
|---|---|
| `cc` | Copy file name |
| `cp` | Copy absolute path |
| `cd` | Copy parent directory path |
| `cf` | Copy filename |
| `cn` | Copy name without extension |

### Sorting (chord: `,`)

| Keys | Sort by |
|---|---|
| `,m` | Modified time |
| `,M` | Modified time (reverse) |
| `,c` | Created time |
| `,C` | Created time (reverse) |
| `,e` | Extension |
| `,E` | Extension (reverse) |
| `,a` | Alphabetical |
| `,A` | Alphabetical (reverse) |
| `,n` | Natural order |
| `,N` | Natural order (reverse) |
| `,s` | Size |
| `,S` | Size (reverse) |

All sorting puts directories first.

### Linemode (chord: `m`)

Display extra info in the file list.

| Keys | Show |
|---|---|
| `ms` | File size |
| `mp` | File permissions |
| `mm` | Last modified time |
| `mn` | None (default) |

---

## Git Tooling

### lazygit

Launch: `lazygit` (or `<leader>gg` inside Neovim)

- **Diff pager:** `delta --dark --paging=never` (syntax-highlighted diffs)
- **Auto-fetch:** enabled
- **Auto-refresh:** enabled
- **Editor:** Neovim
- **Nerd Fonts v3** icons enabled
- **Theme:** Catppuccin Mocha

Default lazygit keybindings apply. Key panels: Files, Branches, Commits, Stash, Reflog. Press `?` inside lazygit for help.

### gh-dash (GitHub Dashboard)

Launch: `gh-dash`

Sections configured:
- **PRs:** My Pull Requests, Needs My Review, Involved
- **Issues:** My Issues, Assigned, Involved
- **Notifications:** All, Created, Participating, Mentioned, Review Requested, Assigned, Subscribed, Team Mentioned

**Custom keybindings:**

| Key | Context | Action |
|---|---|---|
| `g` | Universal | Open `lazygit` in the repo |
| `C` | PRs | Code review — switches to PR worktree with `wt switch pr:<number>` and opens `opencode` with the code-reviewer prompt |

**Diff pager:** `diffnav` (side-by-side diff viewer)

### worktrunk (`wt`)

Git worktree manager for working on multiple branches simultaneously.

```sh
wt                          # list worktrees
wt switch <branch>          # switch to branch in a new worktree
wt switch pr:<number>       # check out a PR in a worktree
wt shell-init nushell       # (run automatically) generates wt.nu init file
```

### Atuin (Shell History)

- **Trigger:** `Ctrl+R` in any shell
- **Style:** compact (single-line entries)
- **Enter behavior:** immediately executes selected command (press `Tab` to return to editor)
- **Sync:** v2 protocol enabled (syncs across machines if logged in)
- **Secrets filter:** enabled by default (won't save AWS keys, GitHub PATs, etc.)

Inside the Atuin TUI:
- `Up/Down` — navigate history
- `Tab` — accept to edit without executing
- `Enter` — execute immediately
- `Ctrl+C` — cancel

---

## CLI Utilities

### zoxide (`z`)

Smart `cd` that learns from your usage. Finds the most frequent/recent match.

```sh
z dotfiles       # jump to ~/dotfiles (or wherever you go most)
z conf nv        # fuzzy: jumps to something like ~/.config/nvim
zi               # interactive selection with fzf
```

### fzf

Fuzzy finder. `FZF_DEFAULT_COMMAND` is set to `fd --type f --hidden --follow` so it finds all files including hidden ones.

```sh
Ctrl+T           # (zsh) fuzzy insert a file path
Alt+C            # (zsh) fuzzy cd into a directory
fv               # fzf-select file and open in nvim
fcd              # fzf-select directory and cd into it
```

### bat

Syntax-highlighted `cat`. Aliased as `cat` in Zsh.

```sh
bat file.lua          # view with syntax highlight
bat --plain file.lua  # no decorations
```

### direnv

Automatically loads/unloads `.envrc` files when entering/leaving directories. The Nushell `pre_prompt` hook calls `direnv export json` before every prompt.

```sh
# In a project directory:
echo 'export DATABASE_URL=...' > .envrc
direnv allow .        # approve the .envrc file
```

### mise (Runtime Version Manager)

Manages language runtimes. Shims are in `~/.local/share/mise/shims/`.

```sh
mise install node@22        # install Node 22
mise use node@22            # set Node 22 for current project
mise ls                     # list installed runtimes
mise current                # show active versions
```

Global config: `~/.config/mise/config.toml`

---

## Starship Prompt

Minimal left side, information-dense right side.

**Left prompt:**
```
~/current/dir ➜
```
In vi normal mode, the arrow becomes:
```
~/current/dir N >>>
```

**Right prompt** (all modules — only shown when data is present):
- Git branch and status
- AWS profile + region
- Go version (shown as ` `)
- Kubernetes context (currently disabled)
- Docker context (currently disabled)

**Config:** `~/.config/starship/starship.toml`

---

## Quick Reference Card

```
NAVIGATION                   FILE OPERATIONS           GIT
──────────────               ───────────────           ───
z <dir>     smart cd         l       eza list          gst   status
cx <dir>    cd + list        lt      tree view         ga    add -p (interactive)
fcd         fzf → cd         cat     bat (highlight)   gc    commit -m "msg"
..  ...     go up 1,2,3      v       nvim              gp    push HEAD
yazi        file manager     fv      fzf → nvim        glog  graph log
                             fcd     fzf → cd          lazygit  full TUI

TMUX (prefix=Ctrl+A)         ZELLIJ                    NEOVIM
────────────────────         ──────                    ──────
prefix+s    split below      Ctrl+A → pane mode        jj/jk   → Normal
prefix+v    split right      Ctrl+T → tab mode         <leader>ot opencode toggle
prefix+h/j/k/l  pane nav    Ctrl+N → resize mode      <leader>oa ask AI
prefix+z    zoom pane        Ctrl+S → scroll mode      sa/sd   surround add/delete
prefix+o    session manager  Alt+hjkl  move focus      gsr     surround replace
prefix+p    float pane       Alt+N   new pane           <leader>ff find files
prefix+u    open URLs        Ctrl+G  lock mode          <leader>gg lazygit

YAZI (file manager)          HISTORY                   TOOLS
───────────────────          ───────                   ─────
hjkl   navigate              Ctrl+R  atuin search      http  = xh (HTTP client)
Space  select file           Enter   run immediately   rg    ripgrep
y/x/p  copy/cut/paste        Tab     edit before run   fd    fast find
d/D    trash/delete                                    wt    git worktrees
s/S    search name/content                             but   gitbutler
z/Z    zoxide/fzf jump                                 turso SQLite edge DB
gh/gc  goto home/config
,m ,s  sort by time/size
```
