return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "swift" },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "LazyFile",
		-- Window handling fix removed - plugin now handles WinClosed internally
		-- If you experience window-related issues, see git history to restore
	},
}
