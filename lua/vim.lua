-- Options
vim.opt.list = true
vim.opt.listchars:append "trail:⋅"
vim.opt.listchars:append "nbsp:⎵"
vim.opt.listchars:append "tab:› "
-- vim.opt.listchars:append "eol:↴"
-- vim.opt.listchars:append "multispace:⋅"
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "trail:␠"

-- Disable NetRW
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Use NetRW command for NvimTree
vim.api.nvim_create_user_command("E", "NvimTreeFocus", {})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)
