return {
	{
		"mason-org/mason.nvim",
		keys = {
			{
				"<leader>ma",
				"<Cmd>Mason<CR>",
				desc = "Toggle Mason menu (Mason)",
			},
		},
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	-- mason-lspconfig.nvim setup handled by LazyVim
	-- LazyVim v15+ uses native vim.lsp.config (Neovim 0.11+)
}
