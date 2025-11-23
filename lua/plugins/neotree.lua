return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                enable_git_status = true,
                default_component_configs = {
                    icon = {
                        folder_closed = "📁",
                        folder_open = "📂",
                        folder_empty = "📁",
                        folder_empty_open = "📂",
                        -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
                        -- then these will never be used.
                        default = "*",
                        highlight = "NeoTreeFileIcon",
                        use_filtered_colors = true,
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
                            modified = "", -- this is redundant info if you use git_status_colors on the name
                            deleted = "✖", -- this can only be used in the git_status source
                            renamed = "󰁕", -- this can only be used in the git_status source
                            -- Status type
                            untracked = "",
                            ignored = "",
                            unstaged = "󰄱",
                            staged = "",
                            conflict = "",
                        },
                    },
                },
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = true,
                    },
                    filtered_items = {
                        visible = true,
                    },
                },
                window = {
                    width = 40,
                    mappings = {
                        ["%"] = "add",
                        ["D"] = "delete",
                        ["R"] = "rename",
                        ["a"] = "", -- I don't want a to do anything
                        ["d"] = "add_directory",
                        ["r"] = "refresh",
                    },
                },
            })
        end,
    },
}
