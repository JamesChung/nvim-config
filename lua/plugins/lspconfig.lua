return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            codelens = {
                enabled = true,
            },
            diagnostics = {
                virtual_text = false,
                virtual_lines = {
                    -- Only show virtual line diagnostics for the current cursor line
                    current_line = true,
                },
            },
            servers = {
                asm_lsp = {},
                bashls = {},
                bufls = {},
                clangd = {
                    on_attach = function(client, bufnr)
                        vim.opt_local.tabstop = 2
                        vim.opt_local.shiftwidth = 2
                    end
                },
                cssls = {
                    settings = {
                        css = {
                            lint = {
                                unknownAtRules = "ignore",
                            }
                        },
                    },
                },
                docker_compose_language_service = {},
                dockerls = {},
                dotls = {},
                gopls = {},
                lua_ls = {},
                pyright = {
                    on_new_config = function(config, root_dir)
                        local venv_path = root_dir .. '/.venv/bin/python'
                        if vim.fn.executable(venv_path) == 1 then
                            config.settings.python.pythonPath = venv_path
                        else
                            -- Fallback to system Python if no .venv is found
                            config.settings.python.pythonPath = vim.fn.exepath('python3') or vim.fn.exepath('python')
                        end
                    end,
                },
                rust_analyzer = {},
                tailwindcss = {},
                terraformls = {},
                ts_ls = {
                    on_attach = function(client, bufnr)
                        -- client.server_capabilities.documentFormattingProvider = false
                        vim.opt_local.tabstop = 2
                        vim.opt_local.shiftwidth = 2
                    end,
                },
                vimls = {},
                yamlls = {
                    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
                },
                zls = {},
            },
        },
    },
}
