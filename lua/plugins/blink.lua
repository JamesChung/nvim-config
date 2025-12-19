return {
    "saghen/blink.cmp",
    opts = {
        keymap = {
            -- Disable enter
            ["<CR>"] = {},
            ["<Tab>"] = {
                "accept",
                "fallback",
            },
            ["<C-space>"] = { "show", "hide" },
        },
        completion = {
            menu = {
                auto_show = false,
            },
            list = {
                selection = {
                    auto_insert = false,
                },
            },
        },
    },
}
