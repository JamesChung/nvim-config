return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "diff",
                "go",
                "hcl",
                "html",
                "java",
                "javascript",
                "jsdoc",
                "json",
                "jsonc",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "rust",
                "sql",
                "terraform",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
                "zig",
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function(_, opts)
            require('treesitter-context').setup(opts)

            -- Add autocmd to handle window changes more gracefully
            vim.api.nvim_create_autocmd({ "WinClosed", "BufWinLeave" }, {
                group = vim.api.nvim_create_augroup("TreesitterContextFix", { clear = true }),
                callback = function()
                    -- Small delay to let window operations complete
                    vim.schedule(function()
                        local ok, context = pcall(require, 'treesitter-context')
                        if ok then
                            -- Safely disable and re-enable context
                            pcall(context.disable)
                            vim.schedule(function()
                                pcall(context.enable)
                            end)
                        end
                    end)
                end,
                desc = "Fix treesitter-context window issues",
            })
        end,
    },
}
