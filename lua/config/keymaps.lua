-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move lines up/down
vim.api.nvim_set_keymap("n", "<A-j>", ":m .+1<CR>==", { noremap = true })
vim.api.nvim_set_keymap("n", "<A-k>", ":m .-2<CR>==", { noremap = true })
vim.api.nvim_set_keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true })
vim.api.nvim_set_keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true })
vim.api.nvim_set_keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true })

-- Move lines up/down for Mac
vim.api.nvim_set_keymap("n", "∆", ":m .+1<CR>==", { noremap = true })
vim.api.nvim_set_keymap("n", "˚", ":m .-2<CR>==", { noremap = true })
vim.api.nvim_set_keymap("i", "∆", "<Esc>:m .+1<CR>==gi", { noremap = true })
vim.api.nvim_set_keymap("i", "˚", "<Esc>:m .-2<CR>==gi", { noremap = true })
vim.api.nvim_set_keymap("v", "∆", ":m '>+1<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("v", "˚", ":m '<-2<CR>gv=gv", { noremap = true })

-- Remap space to be leader rather than the default backslash key
vim.api.nvim_set_keymap("n", "<Space>", "<Leader>", { noremap = true })

-- Set folke/trouble.nvim toggle keybinding
vim.api.nvim_set_keymap("n", "<leader>tt", "<Cmd>TroubleToggle<CR>", { noremap = true, silent = true })

-- Set williamboman/mason.nvim open/close toggle
vim.api.nvim_set_keymap("n", "<leader>ma", "<Cmd>Mason<CR>", { noremap = true, silent = true })
