# James' Neovim Config

## 📦 Installation

### 1. Prerequisites
Ensure you have the core speed-boosters installed:
```bash
brew install fd ripgrep lazygit
```

For **Swift/Xcode** development:
```bash
brew install xcode-build-server xcbeautify
sudo xcodebuild -runFirstLaunch
```

### 2. Clone the Config
```bash
# SSH (Recommended)
git clone git@github.com:JamesChung/nvim-config.git ~/.config/nvim

# HTTPS
git clone https://github.com/JamesChung/nvim-config.git ~/.config/nvim
```

---

## ⌨️ Usage

Refer to the **[KEYMAP.md](./KEYMAP.md)** for the complete manual.

---

## ⚙️ Architecture
- **Plugin Manager:** [Lazy.nvim](https://github.com/folke/lazy.nvim)
- **Base Distribution:** [LazyVim](https://github.com/LazyVim/LazyVim)
- **Theme:** Rose Pine

### ⚠️ Note on `:LazyExtras`
`lazyvim.json` keeps `extras: []` because all 28 extras are imported directly in `lua/config/lazy.lua`. The `:LazyExtras` menu will show these extras as disabled. Don't enable them from `:LazyExtras`, or you will end up with duplicate imports.
