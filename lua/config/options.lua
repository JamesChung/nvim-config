-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Options
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.tabstop = 4           -- Set tab width to 4 spaces
vim.opt.softtabstop = 4       -- Set soft tabstop to 4 spaces
vim.opt.shiftwidth = 4        -- Set indentation width to 4 spaces
vim.opt.smartindent = true    -- Smart autoindenting
vim.opt.shiftround = true     -- Round indent to multiple of shiftwidth
vim.opt.incsearch = true
vim.opt.wildmode = { "longest", "list" }
vim.opt.scrolloff = 10

-- Colors
vim.opt.termguicolors = true

-- List Chars
vim.opt.list = true
vim.opt.listchars:append("trail:⋅")
vim.opt.listchars:append("nbsp:⎵")
vim.opt.listchars:append("tab:  ›")

-- Enable rounded borders in floating windows
vim.o.winborder = "rounded"
