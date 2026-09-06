# Neovim Keymap Reference

A comprehensive guide to keybindings in this configuration, including custom bindings, LazyVim defaults, and plugin-specific shortcuts.

## Table of Contents
- [Mode Legend](#mode-legend)
- [Essential Keys (Quick Start)](#essential-keys-quick-start)
- [LSP Navigation & Actions](#lsp-navigation)
- [File & Buffer Management](#file-management)
- [Git](#git)
- [Search & Replace](#search--replace)
- [Trouble & Diagnostics](#trouble--diagnostics)
- [Xcode (Swift & Apple Platforms)](#xcode-swift--apple-platforms)
- [Terminal & UI Toggles](#terminal--ui-toggles)
- [AI & Development](#ai--development)
- [Debugging (DAP)](#debugging-dap)
- [Java & Swift Development](#java--swift-development)
- [How to use Flash](#how-to-use-flash)
- [System Dependencies](#system-dependencies)

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
| `<leader><space>` | n | Find Files | High-speed project navigation (fff.nvim) |
| `<leader>/` | n | Live Grep | Find any text project-wide (fff.nvim) |
| `gd` | n | Go to Definition | Jump to source code |
| `grr` | n | References | See where code is used (built-in LSP) |
| `<leader>ca` | n, v | Code Action | Quick fixes and refactoring |
| `<leader>gq` | n | Git Quickfix | Actionable list of all changes |
| `s` | n, v | Flash Jump | Teleport to any word on screen |
| `<leader>e` | n | Explorer | Toggle project sidebar |
| `<C-\>` | n, t | Terminal | Toggle floating shell |
| `:Q` | c | Safe Quit | Protect background tasks |

---

## LSP Navigation

*Note: In code buffers, these are mapped via LspAttach for highest priority.*

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `gd` | n | Go to definition | [Snacks.picker](https://github.com/folke/snacks.nvim) (buffer-local) |
| `gD` | n | Go to declaration | [Snacks.picker](https://github.com/folke/snacks.nvim) (buffer-local) |
| `grt` | n | Go to type definition | Built-in LSP |
| `gri` | n | Go to implementation | Built-in LSP |
| `grr` | n | Go to references | Built-in LSP |
| `K` | n | Hover documentation | Native LSP (buffer-local) |
| `gO` | n | Document symbols | Built-in LSP |
| `<leader>ck` | n | Signature help | Buffer-local via LspAttach |
| `]d` | n | Next diagnostic | Built-in |
| `[d` | n | Prev diagnostic | Built-in |
| `]e` | n | Next error | Built-in |
| `[e` | n | Prev error | Built-in |

## LSP Actions

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ca` | n, v | Code action |
| `<D-.>` | n, v | Code action (macOS Cmd+.) |
| `<leader>cr` | n | Rename symbol (LazyVim) |
| `<leader>cf` | n | Format (Standard) |
| `<leader>cd` | n | Line diagnostics |
| `<leader>cl` | n | LSP Info |
| `<leader>cwa` | n | Add workspace folder |
| `<leader>cwr` | n | Remove workspace folder |
| `<leader>cwl` | n | List workspace folders |

---

## File Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader><space>` | n | Find files (FFF) |
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

## Git

| Key | Mode | Action | Plugin |
|-----|------|--------|--------|
| `<leader>gg` | n | Lazygit (Root) | [lazygit](https://github.com/jesseduffield/lazygit) |
| `<leader>gd` | n | Diffview Open | [diffview](https://github.com/sindrets/diffview.nvim) |
| `<leader>gh` | n | Diffview History | |
| `<leader>gq` | n | Git Quickfix | [gitsigns](https://github.com/lewis6991/gitsigns.nvim) |
| `<leader>gb` | n | Git Blame Line | |
| `<leader>gs` | n | Git Status | [Snacks.git](https://github.com/folke/snacks.nvim) |
| `<leader>gS` | n | Git Stash | |

---

## Search & Replace

| Key | Mode | Action |
|-----|------|--------|
| `<leader>/` | n | Grep (FFF) |
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

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>tp` | n | Project Diagnostics | [Trouble.nvim](https://github.com/folke/trouble.nvim) |
| `<leader>tb` | n | Buffer Diagnostics | |
| `<leader>ts` | n | Symbols | |
| `<leader>tl` | n | LSP Definitions/Refs | |
| `<leader>tq` | n | Quickfix List | |
| `<leader>to` | n | Location List | |
| `<leader>xq` | n | Quickfix List | LazyVim core |
| `<leader>xl` | n | Location List | LazyVim core |
| `<leader>xt` | n | Todo | todo-comments |
| `<leader>xT` | n | Todo/Fix/Fixme | todo-comments |
| `]q` | n | Next Trouble/QF item | |
| `[q` | n | Prev Trouble/QF item | |

---

## Xcode (Swift & Apple Platforms)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Xb` | n | Xcode Build |
| `<leader>Xr` | n | Xcode Build & Run |
| `<leader>Xt` | n | Xcode Test |
| `<leader>XT` | n | Xcode Test Target |
| `<leader>Xd` | n | Select Device |
| `<leader>Xp` | n | Select Scheme |
| `<leader>Xl` | n | Toggle Logs |
| `<leader>Xc` | n | Toggle Coverage |

---

## Terminal & UI Toggles

| Key | Mode | Action |
|-----|------|--------|
| `<C-\>` | n, t | Toggle Terminal |
| `<C-`>` | n, t | Toggle Terminal |
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

---

## Debugging (DAP)

| Key | Mode | Action | Plugin |
|-----|------|--------|--------|
| `<leader>dc` | n | Continue / Start | [nvim-dap](https://github.com/mfussenegger/nvim-dap) |
| `<leader>db` | n | Toggle Breakpoint | |
| `<leader>dB` | n | Breakpoint Condition | |
| `<leader>da` | n | Run with Args | |
| `<leader>dC` | n | Run to Cursor | |
| `<leader>dg` | n | Go to Line (No Execute) | |
| `<leader>di` | n | Step Into | |
| `<leader>do` | n | Step Out | |
| `<leader>dO` | n | Step Over | |
| `<leader>dj` | n | Down (Stack Frame) | |
| `<leader>dk` | n | Up (Stack Frame) | |
| `<leader>dl` | n | Run Last session | |
| `<leader>dt` | n | Terminate | |
| `<leader>dp` | n | Pause | |
| `<leader>du` | n | Toggle UI | [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) |
| `<leader>de` | n, v | Eval Expression | |
| `<leader>dr` | n | Toggle REPL | |
| `<leader>ds` | n | Session Info | |
| `<leader>dw` | n | Widgets (Floating info) | |

---

## Java & Swift Development

### 1. Safe Quit Protection (`:Q`, `:Qa`, etc.)
Prevents data loss by checking for active LSP indexing, DAP sessions, Mason installs, and Lazy updates before allowing a quit.

### 2. Unified Formatting (`Conform.nvim`)
Consistent formatting across Java, Swift, Web, and System languages via `<leader>cf`.

### 3. Built-in Visual Diagnostics
Diagnostics render via Neovim's built-in `virtual_lines` on the current line, restoring full source attribution (for example, `Lua Diagnostics: undefined-global: <message>`). `tiny-inline-diagnostic.nvim` was removed in favor of native virtual lines.

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
