-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable NetRW (must be set before plugins load)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Use snacks as the picker (instead of fzf-lua default for install_version < 8)
vim.g.lazyvim_picker = "snacks"

-- Use neo-tree as the explorer (snacks.explorer is disabled in lua/plugins/snacks.lua)
vim.g.lazyvim_explorer = "neo-tree"

-- Options
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 4 -- Set tab width to 4 spaces
vim.opt.softtabstop = 4 -- Set soft tabstop to 4 spaces
vim.opt.shiftwidth = 4 -- Set indentation width to 4 spaces
vim.opt.smartindent = true -- Smart autoindenting
vim.opt.shiftround = true -- Round indent to multiple of shiftwidth
vim.opt.wildmode = { "longest", "list" }
vim.opt.scrolloff = 10

-- List Chars
vim.opt.list = true
vim.opt.listchars:append("trail:⋅")
vim.opt.listchars:append("nbsp:⎵")
vim.opt.listchars:append("tab:  ›")

-- Enable rounded borders in floating windows
vim.o.winborder = "rounded"
