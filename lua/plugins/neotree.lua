return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            "3rd/image.nvim", -- image support in preview window: See `# Preview Mode` for more information
        },
        config = function()
            require("neo-tree").setup({
                enable_git_status = true,
                icon = {
                    folder_closed = "",
                    folder_open = "",
                    folder_empty = "󰜌",
                    -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
                    -- then these will never be used.
                    default = "*",
                    highlight = "NeoTreeFileIcon",
                },
                modified = {
                    symbol = "[+]",
                    highlight = "NeoTreeModified",
                },
                name = {
                    trailing_slash = false,
                    use_git_status_colors = true,
                    highlight = "NeoTreeFileName",
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added = "✚", -- this is redundant info if you use git_status_colors on the name
                        modified = "", -- this is redundant info if you use git_status_colors on the name
                        deleted = "✖", -- this can only be used in the git_status source
                        renamed = "󰁕", -- this can only be used in the git_status source
                        -- Status type
                        untracked = "",
                        ignored = "",
                        unstaged = "󰄱",
                        staged = "",
                        conflict = "",
                    },
                },
                filesystem = {
                    filtered_items = {
                        visible = true,
                    },
                },
                window = {
                    mappings = {
                        ["%"] = "add",
                        ["D"] = "delete",
                        ["R"] = "rename",
                        ["a"] = false,
                        ["d"] = "add_directory",
                        ["r"] = "refresh",
                    },
                },
            })
        end,
    },
}
