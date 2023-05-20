-- Options
vim.opt.list = true
vim.opt.listchars:append "trail:⋅"
vim.opt.listchars:append "nbsp:⎵"
vim.opt.listchars:append "tab:› "
-- vim.opt.listchars:append "eol:↴"
-- vim.opt.listchars:append "multispace:⋅"
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "trail:␠"

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

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

-- Configure nvim-dap settings
vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379", bg = "#31353f" })

vim.fn.sign_define("DapBreakpoint", {
    text = "",
    texthl = "DapBreakpoint",
    linehl = "",
    numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
    text = "ﳁ",
    texthl = "DapBreakpoint",
    linehl = "DapBreakpoint",
    numhl = "",
})
vim.fn.sign_define("DapBreakpointRejected", {
    text = "",
    texthl = "DapBreakpoint",
    linehl = "DapBreakpoint",
    numhl = "",
})
vim.fn.sign_define("DapLogPoint", {
    text = "",
    texthl = "DapLogPoint",
    linehl = "DapLogPoint",
    numhl = "",
})
vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DapStopped",
    linehl = "DapStopped",
    numhl = "",
})
