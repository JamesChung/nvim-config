return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = {
                -- All other parsers are handled by LazyVim core or language extras
                "hcl", -- Terraform uses hcl
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        -- Window handling fix removed - plugin now handles WinClosed internally
        -- If you experience window-related issues, see git history to restore
    },
}
