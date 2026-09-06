return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "swift" },
			highlight = { enable = true },
			indent = { enable = true },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "LazyFile",
		-- Window handling fix removed - plugin now handles WinClosed internally
		-- If you experience window-related issues, see git history to restore
	},
}
