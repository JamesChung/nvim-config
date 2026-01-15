return {
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
		keys = {
			{ "<leader>Xb", "<cmd>XcodebuildBuild<cr>", desc = "Xcode Build" },
			{ "<leader>Xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Xcode Build & Run" },
			{ "<leader>Xt", "<cmd>XcodebuildTest<cr>", desc = "Xcode Test" },
			{ "<leader>XT", "<cmd>XcodebuildTestTarget<cr>", desc = "Xcode Test Target" },
			{ "<leader>Xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device" },
			{ "<leader>Xp", "<cmd>XcodebuildSelectScheme<cr>", desc = "Select Scheme" },
			{ "<leader>Xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Logs" },
			{ "<leader>Xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle Coverage" },
		},
	},
}
