-- Setup language servers.
require("mason-lspconfig").setup()
local lsp = require('lsp-zero').preset({
    float_border = "rounded",
})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    lsp.buffer_autoformat()
    local opts = { buffer = bufnr }
    local bind = vim.keymap.set
    bind('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    bind('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end)

lsp.set_sign_icons({
    -- icons / text used for a diagnostic
    error = "",
    warn = "",
    hint = "",
    info = "",
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

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

local cmp = require('cmp')

cmp.setup({
    mapping = {
        -- `Enter` key to confirm completion
        ['<Tab>'] = cmp.mapping.confirm({ select = false }),

        -- Ctrl+Space to trigger completion menu
        ['<C-Space>'] = cmp.mapping.complete(),
    }
})
