require("fidget").setup {}
require("telescope").setup {}
require("nvim-web-devicons").setup {}
require("gitsigns").setup {}
require("trouble").setup {}
require("lualine").setup {
    extensions = { "quickfix" },
    options = {
        theme = "nightfly",
    },
    sections = {
        lualine_b = {
            {
                "diagnostics",
                symbols = {
                    error = " ",
                    warn = " ",
                    hint = " ",
                    info = " ",
                },
            },
        },
    },
}
require("toggleterm").setup {
    direction = "float",
}
require("deferred-clipboard").setup {
    fallback = "unnamedplus",
    lazy = true,
}
require("nvim-treesitter.configs").setup {
    ensure_installed = {
        "bash", "c", "cpp", "css", "go", "hcl", "html",
        "javascript", "json", "lua", "make", "proto",
        "python", "query", "regex", "rust", "sql",
        "toml", "tsx", "typescript", "yaml", "zig",
    },
    auto_install = true,
    highlight = {
        enabled = true,
    }
}
require("bufferline").setup {
    options = {
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        themable = true,
        diagnostics = "coc",
        sort_by = "insert_at_end",
        hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" }
        },
        get_element_icon = function(element)
            local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = false })
            return icon, hl
        end
    }
}
require('scrollview').setup({
    excluded_filetypes = { 'nerdtree' },
    current_only = true,
    winblend = 75,
    base = 'buffer',
    column = 120,
    signs_on_startup = { 'all' },
    diagnostics_severities = { vim.diagnostic.severity.ERROR }
})
require('nvim-autopairs').setup({
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    disable_in_macro = true,        -- disable when recording or executing a macro
    disable_in_visualblock = false, -- disable when insert after visual block mode
    disable_in_replace_mode = true,
    ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    enable_moveright = true,
    enable_afterquote = false,        -- add bracket pairs after quote
    enable_check_bracket_line = true, -- check bracket in same line
    enable_bracket_in_quote = false,
    enable_abbr = false,              -- trigger abbreviation
    break_undo = true,                -- switch for basic rule break undo sequence
    check_ts = false,
    map_cr = true,
    map_bs = false,  -- map the <BS> key
    map_c_h = false, -- Map the <C-h> key to delete a pair
    map_c_w = false, -- map <c-w> to delete a pair if possible
})
