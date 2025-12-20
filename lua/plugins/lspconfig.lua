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
                cssls = {
                    settings = {
                        css = {
                            lint = {
                                unknownAtRules = "ignore",
                            }
                        },
                    },
                },
                dotls = {},
                gradle_ls = {
                    init_options = {
                        settings = {
                            gradleWrapperEnabled = true,
                        },
                    },
                },
                lua_ls = {},
                sourcekit = {
                    capabilities = {
                        workspace = {
                            didChangeWatchedFiles = {
                                dynamicRegistration = true,
                            },
                        },
                    },
                },
                vimls = {},
            },
        },
    },
}
