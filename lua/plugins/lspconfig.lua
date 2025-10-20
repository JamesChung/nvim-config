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
                bashls = {},
                bufls = {},
                clangd = {},
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
                sourcekit = {
                    capabilities = {
                        workspace = {
                            didChangeWatchedFiles = {
                                dynamicRegistration = true,
                            },
                        },
                    },
                },
                tailwindcss = {},
                terraformls = {},
                ts_ls = {},
                vimls = {},
                yamlls = {
                    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
                },
                zls = {
                    settings = {
                        zls = {
                            enable_inlay_hints = true,
                            enable_snippets = true,
                            warn_style = true,
                        },
                    },
                },
            },
        },
    },
}
