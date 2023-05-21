-- Setup language servers.
require("mason-lspconfig").setup()
local lsp = require("lsp-zero").preset({
    float_border = "rounded",
})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    lsp.buffer_autoformat()
    local opts = { buffer = bufnr }
    local bind = vim.keymap.set
    bind("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    bind("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
end)

lsp.set_sign_icons({
    -- icons / text used for a diagnostic
    error = "",
    warn = "",
    hint = "",
    info = "",
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig")
lspconfig.bashls.setup {
    capabilities = capabilities,
}
lspconfig.clangd.setup {
    capabilities = capabilities,
}
lspconfig.denols.setup {
    capabilities = capabilities,
}
lspconfig.docker_compose_language_service.setup {
    capabilities = capabilities,
}
lspconfig.dockerls.setup {
    capabilities = capabilities,
}
lspconfig.dotls.setup {
    capabilities = capabilities,
}
lspconfig.eslint.setup {
    capabilities = capabilities,
}
lspconfig.gopls.setup {
    capabilities = capabilities,
}
lspconfig.jsonls.setup {
    capabilities = capabilities,
}
lspconfig.pyright.setup {
    capabilities = capabilities,
}
lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
}
lspconfig.terraformls.setup {
    capabilities = capabilities,
}
lspconfig.tsserver.setup {
    capabilities = capabilities,
}
lspconfig.vimls.setup {
    capabilities = capabilities,
}
lspconfig.yamlls.setup {
    capabilities = capabilities,
}
lspconfig.zls.setup {
    capabilities = capabilities,
}

lsp.setup()

local cmp = require("cmp")

cmp.setup({
    mapping = {
        -- `Enter` key to confirm completion
        ["<Tab>"] = cmp.mapping.confirm({ select = false }),

        -- Ctrl+Space to trigger completion menu
        ["<C-Space>"] = cmp.mapping.complete(),
    }
})

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
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

-- Allow LSP context highlighting on cursor
vim.api.nvim_create_augroup("CursorHighlightGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CursorHighlightGroup",
    command = "lua vim.lsp.buf.document_highlight()",
    desc = "Highlight symbol under cursor on CursorHold",
})
vim.api.nvim_create_autocmd("CursorHoldI", {
    group = "CursorHighlightGroup",
    command = "lua vim.lsp.buf.document_highlight()",
    desc = "Highlight symbol under cursor on CursorHoldI",
})
vim.api.nvim_create_autocmd("CursorMoved", {
    group = "CursorHighlightGroup",
    command = "lua vim.lsp.buf.clear_references()",
    desc = "Clear highlight references when cursor is moved",
})
