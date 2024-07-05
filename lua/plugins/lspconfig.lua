return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "VonHeikemen/lsp-zero.nvim",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local lsp_zero = require("lsp-zero").preset({
                float_border = "rounded",
            })

            -- For mason-lspconfig
            lsp_zero.extend_lspconfig()

            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.buffer_autoformat()
            end)

            lsp_zero.set_sign_icons({
                -- icons / text used for a diagnostic
                error = "✘",
                warn = "▲",
                hint = "⚑",
                info = "»",
            })

            local lspconfig = require("lspconfig")
            local lsputil = require("lspconfig/util")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            lspconfig.astro.setup({
                capabilities = capabilities,
            })
            lspconfig.bashls.setup({
                capabilities = capabilities,
            })
            lspconfig.bufls.setup({
                capabilities = capabilities,
            })
            lspconfig.clangd.setup({
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    vim.opt_local.tabstop = 2
                    vim.opt_local.shiftwidth = 2
                end
            })
            lspconfig.docker_compose_language_service.setup({
                capabilities = capabilities,
            })
            lspconfig.dockerls.setup({
                capabilities = capabilities,
            })
            lspconfig.dotls.setup({
                capabilities = capabilities,
            })
            lspconfig.gopls.setup({
                capabilities = capabilities,
                cmd = { "gopls", "serve" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
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
                        end,
                    })
                end,
            })
            lspconfig.lua_ls.setup({
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
            })
            lspconfig.pyright.setup({
                capabilities = capabilities,
            })
            lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
            })
            lspconfig.terraformls.setup({
                capabilities = capabilities,
            })
            lspconfig.tsserver.setup({
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    client.server_capabilities.documentFormattingProvider = false
                end,
            })
            lspconfig.vimls.setup({
                capabilities = capabilities,
            })
            lspconfig.yamlls.setup({
                capabilities = capabilities,
                filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
            })
            lspconfig.zls.setup({
                capabilities = capabilities,
            })

            local cmp = require("cmp")
            -- local cmp_action = lsp.cmp_action()

            cmp.setup({
                completion = {
                    autocomplete = false,
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
        end,
    },
}
