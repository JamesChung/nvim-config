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
}
