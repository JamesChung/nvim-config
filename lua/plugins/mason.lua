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
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "VonHeikemen/lsp-zero.nvim",
        },
        config = function()
            local lsp_zero = require("lsp-zero")
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "bashls",
                    "dotls",
                    "html",
                    "lua_ls",
                },
                handlers = {
                    lsp_zero.default_setup,
                },
            })
        end,
    },
}
