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
