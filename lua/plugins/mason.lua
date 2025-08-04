return {
  {
    "williamboman/mason.nvim",
    -- Have to pin to major version 1 temporarily
    -- https://github.com/LazyVim/LazyVim/issues/6039#issuecomment-2856227817
    version = "^1.0.0",
    keys = {
      {
        "<leader>ma",
        "<Cmd>Mason<CR>",
        "Toggle Mason menu (Mason)",
      },
    },
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    -- Have to pin to major version 1 temporarily
    -- https://github.com/LazyVim/LazyVim/issues/6039#issuecomment-2856227817
    version = "^1.0.0",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "zls", -- Zig Language Server
        },
        automatic_installation = true,
      })
    end,
  },
}
