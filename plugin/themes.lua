require("rose-pine").setup({
    --- @usage "auto"|"main"|"moon"|"dawn"
    variant = "moon",
    --- @usage "main"|"moon"|"dawn"
    -- dark_variant = "main",
    -- bold_vert_split = false,
    -- dim_nc_background = false,
    -- disable_background = false,
    -- disable_float_background = false,
    -- disable_italics = false,

    --- @usage string hex value or named color from rosepinetheme.com/palette
    -- groups = {
    -- background = "base",
    -- background_nc = "_experimental_nc",
    -- panel = "surface",
    -- panel_nc = "base",
    -- border = "highlight_med",
    -- comment = "muted",
    -- link = "iris",
    -- punctuation = "subtle",

    -- error = "love",
    -- hint = "iris",
    -- info = "foam",
    -- warn = "gold",

    -- headings = {
    --     h1 = "iris",
    --     h2 = "foam",
    --     h3 = "rose",
    --     h4 = "gold",
    --     h5 = "pine",
    --     h6 = "foam",
    -- }
    -- or set all headings at once
    -- headings = "subtle"
    -- },

    -- Change specific vim highlight groups
    -- https://github.com/rose-pine/neovim/wiki/Recipes
    highlight_groups = {
        FloatBorder = { bg = "iris", blend = 10 },
        -- CursorColumn = { bg = "#44415a" }
        -- ColorColumn = { bg = "rose" },

        -- Blend colours against the "base" background
        -- CursorLine = { bg = "foam", blend = 10 },
        -- StatusLine = { fg = "love", bg = "love", blend = 10 },
    }
})

-- Themes
-- vim.cmd("colorscheme onedark")
-- vim.cmd("colorscheme onelight")
-- vim.cmd("colorscheme onedark_vivid")
-- vim.cmd("colorscheme onedark_dark")
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme catppuccin-latte")
-- vim.cmd("colorscheme catppuccin-frappe")
-- vim.cmd("colorscheme catppuccin-macchiato")
-- vim.cmd("colorscheme catppuccin-mocha")
vim.cmd("colorscheme rose-pine")
-- vim.cmd("colorscheme rose-pine-moon")
-- vim.cmd("colorscheme rose-pine-dawn")
-- vim.cmd("colorscheme tokyonight")
-- vim.cmd("colorscheme tokyonight-night")
-- vim.cmd("colorscheme tokyonight-storm")
-- vim.cmd("colorscheme tokyonight-day")
-- vim.cmd("colorscheme tokyonight-moon")
