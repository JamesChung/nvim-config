vim.opt.list = true
vim.opt.listchars:append "trail:⋅"
vim.opt.listchars:append "nbsp:⎵"
vim.opt.listchars:append "tab:› "
vim.opt.listchars:append "eol:↴"
-- vim.opt.listchars:append "multispace:⋅"
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "trail:␠"

-- Themes

-- vim.cmd("colorscheme onedark")
-- vim.cmd("colorscheme onelight")
-- vim.cmd("colorscheme onedark_vivid")
-- vim.cmd("colorscheme onedark_dark")
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme catppuccin-latte")
-- vim.cmd("colorscheme catppuccin-frappe")
-- vim.cmd("colorscheme catppuccin-macchiato")
-- vim.cmd("colorscheme catppuccin-mocha")
-- vim.cmd("colorscheme rose-pine")
vim.cmd("colorscheme rose-pine-moon")
-- vim.cmd("colorscheme rose-pine-dawn")
-- vim.cmd("colorscheme tokyonight")
-- vim.cmd("colorscheme tokyonight-night")
-- vim.cmd("colorscheme tokyonight-storm")
-- vim.cmd("colorscheme tokyonight-day")
-- vim.cmd("colorscheme tokyonight-moon")

-- Override theme highlight color
vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#44415a" })
