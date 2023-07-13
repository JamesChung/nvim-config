-- Setup language servers.
require("mason").setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        }
    }
}
require("mason-lspconfig").setup {
    ensure_installed = {
        "bashls", "bufls", "clangd", "denols",
        "docker_compose_language_service", "dockerls",
        "dotls", "eslint", "golangci_lint_ls",
        "html", "jsonls", "lua_ls", "pyright",
        "tsserver", "vimls", "yamlls",
    },
}
local lsp = require("lsp-zero").preset({
    float_border = "rounded",
})

lsp.on_attach(function(client, bufnr)
    lsp.buffer_autoformat()
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
local lsputil = require("lspconfig/util")
local configs = require("lspconfig/configs")

lspconfig.bashls.setup {
    capabilities = capabilities,
}
lspconfig.bufls.setup {
    capabilities = capabilities,
}
lspconfig.clangd.setup {
    capabilities = capabilities,
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
}
lspconfig.denols.setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
    end,
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
if not configs.golangcilsp then
    configs.golangcilsp = {
        default_config = {
            cmd = { "golangci-lint-langserver" },
            root_dir = lspconfig.util.root_pattern(
                ".golangci.yml", ".golangci.yaml",
                ".golangci.toml", ".golangci.json",
                "go.work", "go.mod", ".git"
            ),
            init_options = {
                command = {
                    "golangci-lint", "run",
                    "--out-format", "json",
                    "--issues-exit-code=1",
                },
            }
        },
    }
end
lspconfig.golangci_lint_ls.setup {
    capabilities = capabilities,
    filetypes = { 'go', 'gomod' }
}
lspconfig.gopls.setup {
    capabilities = capabilities,
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    root_dir = lsputil.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
    on_attach = function(client, bufnr)
        vim.o.expandtab = false
        -- Organize imports on save using logic of goimports
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
                vim.lsp.buf.code_action({
                    context = {
                        only = { "source.organizeImports" },
                    },
                    apply = true,
                })
            end
        })
    end,
}
lspconfig.jsonls.setup {
    capabilities = capabilities,
}
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
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
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
    end,
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
-- local cmp_action = lsp.cmp_action()

cmp.setup({
    completion = {
        autocomplete = false
    },
    mapping = {
        -- `Tab` key to confirm completion
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
        -- ["<Tab>"] = cmp_action.tab_complete(),
        -- ["<S-Tab>"] = cmp_action.select_prev_or_fallback(),

        -- Ctrl+Space to trigger completion menu
        ["<C-Space>"] = cmp.mapping.complete(),
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
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
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

-- Allow LSP context highlighting on cursor
vim.api.nvim_create_augroup("CursorHighlightGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CursorHighlightGroup",
    command = "silent! lua vim.lsp.buf.document_highlight()",
    desc = "Highlight symbol under cursor on CursorHold",
})
vim.api.nvim_create_autocmd("CursorHoldI", {
    group = "CursorHighlightGroup",
    command = "silent! lua vim.lsp.buf.document_highlight()",
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
