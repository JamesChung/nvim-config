return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { 'neovim/nvim-lspconfig' },
        },
        config = function()
            local lspconfig = require("lspconfig")
            local lsputil = require("lspconfig/util")
            --Enable (broadcasting) snippet capability for completion
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            lspconfig.asm_lsp.setup({
                capabilities = capabilities,
            })
            lspconfig.bashls.setup({
                capabilities = capabilities,
            })
            lspconfig.bufls.setup({
                capabilities = capabilities,
            })
            lspconfig.clangd.setup({
                on_attach = function(client, bufnr)
                    vim.opt_local.tabstop = 2
                    vim.opt_local.shiftwidth = 2
                end
            })
            lspconfig.cssls.setup({
                capabilities = capabilities,
                settings = {
                    css = {
                        validate = true,
                        lint = {
                            unknownAtRules = "ignore",
                        }
                    },
                },
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
            lspconfig.tailwindcss.setup({
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
        end,
    },
}
