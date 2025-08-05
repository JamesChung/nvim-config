return {
  {
    "williamboman/mason.nvim",
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
