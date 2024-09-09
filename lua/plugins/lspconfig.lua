return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { 'VonHeikemen/lsp-zero.nvim', branch = 'v4.x' },
            { 'neovim/nvim-lspconfig' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/nvim-cmp' },
        },
        config = function()
            local lsp_zero = require("lsp-zero")

            local lsp_attach = function(client, bufnr)
                -- Check if the client supports formatting
                if client.server_capabilities.documentFormattingProvider then
                    lsp_zero.buffer_autoformat()
                end
            end

            -- For mason-lspconfig
            lsp_zero.extend_lspconfig({
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
                float_border = "rounded",
                lsp_attach = lsp_attach,
                sign_text = true,
            })

            lsp_zero.on_attach(function(client, bufnr)
                -- Check if the client supports formatting
                if client.server_capabilities.documentFormattingProvider then
                    lsp_zero.buffer_autoformat()
                end
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

            lspconfig.asm_lsp.setup {
                capabilities = capabilities,
            }
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
                on_new_config = function(config, root_dir)
                    local venv_path = root_dir .. '/.venv/bin/python'
                    if vim.fn.executable(venv_path) == 1 then
                        config.settings.python.pythonPath = venv_path
                    else
                        -- Fallback to system Python if no .venv is found
                        config.settings.python.pythonPath = vim.fn.exepath('python3') or vim.fn.exepath('python')
                    end
                end,
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
                    -- client.server_capabilities.documentFormattingProvider = false
                    vim.opt_local.tabstop = 2
                    vim.opt_local.shiftwidth = 2
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

            ---
            -- Autocompletion setup
            ---
            local cmp = require('cmp')

            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                },
                snippet = {
                    expand = function(args)
                        -- You need Neovim v0.10 to use vim.snippet
                        vim.snippet.expand(args.body)
                    end,
                },
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
