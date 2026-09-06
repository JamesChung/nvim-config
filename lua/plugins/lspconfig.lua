return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			codelens = {
				enabled = true,
			},
			diagnostics = {
				virtual_text = false,
				virtual_lines = false,
			},
			servers = {
				-- Disables LazyVim's buffer-local `nowait` `gr` -> lsp_references, which
				-- makes built-in `grn`/`grr`/`gri`/`gra`/`grt` UNREACHABLE on LSP attach.
				-- Must live under servers["*"].keys (opts_extend = "servers.*.keys"), NOT
				-- the spec's top-level `keys` -- there it is a silent no-op.
				["*"] = {
					keys = {
						{ "gr", false },
					},
				},
				bashls = {},
				cssls = {
					settings = {
						css = {
							lint = {
								unknownAtRules = "ignore",
							},
						},
					},
				},
				dotls = {},
				gradle_ls = {},
				lua_ls = {},
				sourcekit = {
					cmd = { "sourcekit-lsp" },
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
