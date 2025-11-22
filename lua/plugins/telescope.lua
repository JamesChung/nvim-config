return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {
            "<leader>tf",
            "<Cmd>Telescope find_files<CR>",
            desc = "Find Files (Telescope)",
        },
        {
            "<leader>tg",
            "<Cmd>Telescope live_grep<CR>",
            desc = "Live Grep (Telescope)",
        },
        {
            "<leader>tb",
            "<Cmd>Telescope buffers<CR>",
            desc = "Show Buffers (Telescope)",
        },
        {
            "<leader>th",
            "<Cmd>Telescope help_tags<CR>",
            desc = "Show help tags (Telescope)",
        },
    },
    opts = {
        defaults = {
            -- Respect gitignore and exclude certain files
            file_ignore_patterns = {
                "%.git/",
                "node_modules/",
            },
        },
        pickers = {
            find_files = {
                -- Use fd to respect gitignore by default
                find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
            },
        },
    },
}
