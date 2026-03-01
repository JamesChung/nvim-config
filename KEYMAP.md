# Neovim Keymap Reference

A comprehensive guide to all keybindings in this configuration, including custom bindings, LazyVim defaults, and plugin-specific shortcuts.

## Table of Contents
- [Mode Legend](#mode-legend)
- [Essential Keys (Quick Start)](#essential-keys-quick-start)
- [LSP Navigation & Actions](#lsp-navigation)
- [File & Buffer Management](#file-management)
- [Git & GitHub (Octo)](#git--github)
- [Search & Replace (Snacks)](#search--replace)
- [Trouble & Diagnostics](#trouble--diagnostics)
- [Terminal & UI Toggles](#terminal--ui-toggles)
- [AI & Development (Java/Swift/Test)](#ai--development)
- [Pro Workflow Features](#pro-workflow-features)
- [How to use Flash](#how-to-use-flash)

---

## Mode Legend

| Abbrev | Mode | Description |
|--------|------|-------------|
| **n** | Normal | Command navigation |
| **v** | Visual | Text selection |
| **i** | Insert | Text editing |
| **t** | Terminal | Integrated shell |
| **c** | Command | `:` prompt |

---

## Essential Keys (Quick Start)

| Key | Mode | Action | Why? |
|-----|------|--------|------|
| `<leader>ff` | n | Find Files | High-speed project navigation |
| `<leader>fg` | n | Live Grep | Find any text project-wide |
| `gd` | n | Go to Definition | Jump to source code |
| `gr` | n | References | See where code is used |
| `<leader>ca` | n, v | Code Action | Quick fixes and refactoring |
| `<leader>gq` | n | Git Quickfix | Actionable list of all changes |
| `s` | n, v | Flash Jump | Teleport to any word on screen |
| `<leader>e` | n | Explorer | Toggle project sidebar |
| `<C-/>` | n, t | Terminal | Toggle floating shell |
| `:Q` | c | Safe Quit | Protect background tasks |

---

## LSP Navigation

*Note: In code buffers, these are mapped via LspAttach for highest priority.*

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `gd` | n | Go to definition | [Snacks.picker](https://github.com/folke/snacks.nvim) |
| `gD` | n | Go to declaration | |
| `gt` | n | Go to type definition | |
| `gi` | n | Go to implementation | |
| `gr` | n | Go to references | |
| `K` | n | Hover documentation | Native |
| `gO` | n | Document symbols | Native |
| `<C-k>` | n, i | Signature help | |
| `]d` | n | Next diagnostic | |
| `[d` | n | Prev diagnostic | |
| `]e` | n | Next error | |
| `[e` | n | Prev error | |

## LSP Actions

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ca` | n, v | Code action |
| `<D-.>` | n, v | Code action (macOS Cmd+.) |
| `<leader>rn` | n | Rename symbol (Mnemonic) |
| `<leader>cr` | n | Rename symbol (LazyVim) |
| `<leader>cf` | n | Format (Standard) |
| `<leader>f` | n | Format (Custom mnemonic) |
| `<leader>cd` | n | Line diagnostics |
| `<leader>cl` | n | LSP Info |

---

## File Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files (Root Dir) |
| `<leader>fF` | n | Find files (cwd) |
| `<leader>fr` | n | Recent files (Root) |
| `<leader>fR` | n | Recent files (cwd) |
| `<leader>e` | n | Explorer (Root) |
| `<leader>E` | n | Explorer (cwd) |
| `:E` | c | Open Neotree |
| `<leader>fc` | n | Find Config File |
| `<leader>fn` | n | New File |

## Buffer Management

| Key | Mode | Action |
|-----|------|--------|
| `H` | n | Previous buffer |
| `L` | n | Next buffer |
| `<leader>bb` | n | Switch to other buffer |
| `,` | n | Switch buffer (LazyVim) |
| `<leader>bd` | n | Delete buffer (Snacks) |
| `:BD` | c | Delete buffer (Preserve layout) |
| `<leader>bp` | n | Toggle Pin |
| `<leader>bP` | n | Delete Non-Pinned |

---

## Git & GitHub

| Key | Mode | Action | Plugin |
|-----|------|--------|--------|
| `<leader>gg` | n | Lazygit (Root) | [lazygit](https://github.com/jesseduffield/lazygit) |
| `<leader>gd` | n | Diffview Open | [diffview](https://github.com/sindrets/diffview.nvim) |
| `<leader>gh` | n | Diffview History | |
| `<leader>gq` | n | Git Quickfix | [gitsigns](https://github.com/lewis6991/gitsigns.nvim) |
| `<leader>gb` | n | Git Blame Line | |
| `<leader>gs` | n | Git Status | [Snacks.git](https://github.com/folke/snacks.nvim) |
| `<leader>gS` | n | Git Stash | |
| `gi` | n | GitHub Issues (open) | [octo.nvim](https://github.com/pwntester/octo.nvim) |
| `gI` | n | GitHub Issues (all) | |
| `gp` | n | GitHub PRs (open) | |
| `gP` | n | GitHub PRs (all) | |

---

## Search & Replace

| Key | Mode | Action |
|-----|------|--------|
| `<leader>/` | n | Grep (Root Dir) |
| `<leader>sg` | n | Grep (Root Dir) |
| `<leader>sG` | n | Grep (cwd) |
| `<leader>sw` | n | Search Word (Root) |
| `<leader>sk` | n | Search Keymaps |
| `<leader>sh` | n | Search Help |
| `<leader>sj` | n | Search Jumps |
| `<leader>sm` | n | Search Marks |
| `<leader>sr` | n | Search & Replace (Grug-far) |
| `s` | n, v | Flash Jump |
| `S` | n | Flash Treesitter |

---

## Trouble & Diagnostics

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tt` | n | Project Diagnostics |
| `<leader>tX` | n | Buffer Diagnostics |
| `<leader>ts` | n | Symbols |
| `<leader>tl` | n | LSP Definitions/Refs |
| `<leader>tQ` | n | Quickfix List |
| `<leader>tL` | n | Location List |
| `<leader>xt` | n | Todo List |
| `]q` | n | Next Trouble/QF item |
| `[q` | n | Prev Trouble/QF item |

---

## Terminal & UI Toggles

| Key | Mode | Action |
|-----|------|--------|
| `<C-/>` | n, t | Toggle Terminal |
| `<C-t>` | n, t | Toggle Terminal |
| `` <C-`> `` | n, t | Toggle Terminal |
| `:SnacksTerminal` | c | Toggle terminal |
| `<C-[>` | t | Exit Terminal Mode |
| `<leader>uf` | n | Toggle Auto-format |
| `<leader>ul` | n | Toggle Line Numbers |
| `<leader>uL` | n | Toggle Relative Numbers |
| `<leader>un` | n | Dismiss Notifications |

---

## AI & Development

### AI (Claude Code)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | n | Toggle Claude |
| `<leader>af` | n | Focus Claude |
| `<leader>aa` | n | Accept Diff |
| `<leader>ad` | n | Deny Diff |

### Java & Swift
| Key | Mode | Action | Plugin |
|-----|------|--------|--------|
| `<leader>jc` | n | Java: Compile | [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) |
| `<leader>jr` | n | Java: Set Runtime | |
| `<leader>xb` | n | Swift: Xcode Build | [xcodebuild](https://github.com/wojciech-kulik/xcodebuild.nvim) |
| `<leader>xr` | n | Swift: Xcode Run | |
| `<leader>xt` | n | Swift: Xcode Test | |
| `<leader>xl` | n | Swift: Toggle Logs | |
| `<leader>xd` | n | Swift: Select Device | |
| `<leader>xp` | n | Swift: Select Scheme | |

### Testing (Neotest)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>TT` | n | Run File |
| `<leader>Tr` | n | Run Nearest |
| `<leader>Ts` | n | Toggle Summary |

---

## Pro Workflow Features

### 1. Safe Quit Protection (`:Q`, `:Qa`, etc.)
Prevents data loss by scanning for active LSP indexing, DAP sessions, Mason installs, and Lazy updates before allowing a quit.

### 2. Unified Formatting (`Conform.nvim`)
Consistent formatting across Java, Swift, Web, and System languages via `<leader>cf` or `<leader>f`.

### 3. Advanced Visual Diagnostics
[tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim) provides sleek, multi-line popups on the cursor line, identifying the specific LSP source.

### 4. GitHub Integration
[octo.nvim](https://github.com/pwntester/octo.nvim) allows you to manage Issues and PRs without leaving the editor using `gi`, `gp`, etc.

---

## How to use Flash

1. Press **`s`**.
2. Type 1-3 characters of your target word.
3. Type the **label** (e.g., `a`, `s`, `f`) that appears to teleport.
4. Use **`S`** for structural Treesitter selection.

---

## System Dependencies

For the best experience, ensure these tools are installed on your system:

### 1. Swift & Xcode
* **`xcode-build-server`**: The bridge between Xcode projects and Neovim LSP.
  ```bash
  brew install xcode-build-server
  ```
* **`xcbeautify`**: Required for clean, formatted logs in the floating window.
  ```bash
  brew install xcbeautify
  ```

### 2. Java
* **`palantir-java-format`**: The native binary must be compiled and placed in your path.
  * See `lua/plugins/formatting.lua` for build instructions.

### 3. General Utilities
* **`fd`**: High-speed file searching (used by Snacks/Telescope).
  ```bash
  brew install fd
  ```
* **`ripgrep` (rg)**: High-speed text searching (used for Grep).
  ```bash
  brew install ripgrep
  ```
* **`lazygit`**: The primary Git interface.
  ```bash
  brew install lazygit
  ```

