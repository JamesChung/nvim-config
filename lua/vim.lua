vim.opt.list = true
vim.opt.listchars:append "trail:⋅"
vim.opt.listchars:append "nbsp:⎵"
vim.opt.listchars:append "tab:› "
-- vim.opt.listchars:append "multispace:⋅"
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "trail:␠"
-- vim.opt.listchars:append "eol:↴"

require("rose-pine").setup({
    --- @usage "auto"|"main"|"moon"|"dawn"
    variant = "moon",
})
-- Set colorscheme after options
vim.cmd("colorscheme rose-pine")
-- Override theme highlight color
vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#44415a" })
