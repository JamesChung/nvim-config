-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Options
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.tabstop = 4           -- Set tab width to 4 spaces
vim.opt.softtabstop = 4       -- Set soft tabstop to 4 spaces
vim.opt.shiftwidth = 4        -- Set indentation width to 4 spaces
vim.opt.smartindent = true    -- Smart autoindenting
vim.opt.shiftround = true     -- Round indent to multiple of shiftwidth
vim.opt.incsearch = true
vim.opt.wildmode = { "longest", "list" }
vim.opt.scrolloff = 10

-- Colors
vim.opt.termguicolors = true

-- List Chars
vim.opt.list = true
vim.opt.listchars:append("trail:⋅")
vim.opt.listchars:append("nbsp:⎵")
vim.opt.listchars:append("tab:  ›")

-- Enable rounded borders in floating windows
vim.o.winborder = "rounded"

-- Fix for LSP floating window width error
-- This needs to be set early, before LSP loads
-- Monkey-patch nvim_open_win to validate width/height
local original_open_win = vim.api.nvim_open_win
vim.api.nvim_open_win = function(buffer, enter, config)
    -- Ensure width and height are valid positive integers
    if config.width and config.width < 1 then
        config.width = 30
    end
    if config.height and config.height < 1 then
        config.height = 1
    end

    return original_open_win(buffer, enter, config)
end

-- Intercept open_floating_preview early to add placeholder for empty content
local orig_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts)
    -- Check if contents is empty
    local has_content = false
    if type(contents) == "table" and #contents > 0 then
        for _, line in ipairs(contents) do
            if line and line:match("%S") then
                has_content = true
                break
            end
        end
    elseif type(contents) == "string" and contents:match("%S") then
        has_content = true
    end

    -- If no content, replace with placeholder
    if not has_content then
        contents = { "No documentation available" }
    end

    return orig_open_floating_preview(contents, syntax, opts)
end
