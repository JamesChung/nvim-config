-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<D-.>", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
    end,
})

-- Allow LSP context highlighting on cursor
vim.api.nvim_create_augroup("CursorHighlightGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CursorHighlightGroup",
    callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
            if client.server_capabilities.documentHighlightProvider then
                pcall(vim.lsp.buf.document_highlight)
                return -- Stop after finding a server that supports it
            end
        end
    end,
    desc = "Highlight symbol under cursor on CursorHold",
})
vim.api.nvim_create_autocmd("CursorHoldI", {
    group = "CursorHighlightGroup",
    callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
            if client.server_capabilities.documentHighlightProvider then
                pcall(vim.lsp.buf.document_highlight)
                return -- Stop after finding a server that supports it
            end
        end
    end,
    desc = "Highlight symbol under cursor on CursorHoldI",
})
vim.api.nvim_create_autocmd("CursorMoved", {
    group = "CursorHighlightGroup",
    command = "silent! lua vim.lsp.buf.clear_references()",
    desc = "Clear highlight references on CursorMoved",
})
vim.api.nvim_create_autocmd("CursorMovedI", {
    group = "CursorHighlightGroup",
    command = "silent! lua vim.lsp.buf.clear_references()",
    desc = "Clear highlight references on CursorMovedI",
})

-- Disable NetRW
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Use NetRW command for Neotree
vim.api.nvim_create_user_command("E", "Neotree", {})

-- Auto-detect indentation
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, 100, false)
        local tab_count = 0
        local space_counts = {}

        for _, line in ipairs(lines) do
            local leading = line:match("^%s*")
            if #leading > 0 then
                if leading:match("^\t") then
                    tab_count = tab_count + 1
                elseif leading:match("^ ") then
                    local spaces = #leading
                    space_counts[spaces] = (space_counts[spaces] or 0) +
                        1
                end
            end
        end

        if tab_count > 0 then
            vim.opt_local.expandtab = false
        else
            -- Find the GCD (greatest common divisor) of all indentation levels
            local indent_levels = {}
            for spaces, _ in pairs(space_counts) do
                table.insert(indent_levels, spaces)
            end

            local function gcd(a, b)
                while b ~= 0 do
                    a, b = b, a % b
                end
                return a
            end

            local common_indent = 0
            if #indent_levels > 0 then
                common_indent = indent_levels[1]
                for i = 2, #indent_levels do
                    common_indent = gcd(common_indent, indent_levels[i])
                end

                -- Ensure reasonable bounds (2, 4, or 8 spaces)
                if common_indent == 1 or common_indent > 8 then
                    common_indent = 4
                elseif common_indent == 3 or common_indent == 5 or common_indent == 6 or common_indent == 7 then
                    common_indent = 4
                end
            end

            if common_indent > 0 then
                vim.opt_local.tabstop = common_indent
                vim.opt_local.softtabstop = common_indent
                vim.opt_local.shiftwidth = common_indent
                vim.opt_local.expandtab = true
            else
                -- Default to 4 spaces if unable to detect
                vim.opt_local.tabstop = 4
                vim.opt_local.softtabstop = 4
                vim.opt_local.shiftwidth = 4
                vim.opt_local.expandtab = true
            end
        end
    end,
    desc = "Auto-detect indentation on file read",
})
