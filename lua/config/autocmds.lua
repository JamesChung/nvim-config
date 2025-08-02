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
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
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
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
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
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
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
