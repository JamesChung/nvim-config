return {
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			logs = {
				auto_open_on_success_tests = false,
				auto_open_on_failed_tests = true,
				auto_open_on_success_build = false,
				auto_open_on_failed_build = true,
				auto_focus = true,
				-- Use Snacks.win for a perfectly centered, robust floating window
				open_command = "lua require('xcodebuild.util').open_float('{path}', 'xcodebuildlog')",
			},
			test_explorer = {
				enabled = true,
				auto_open = true,
				-- Open Test Explorer in a centered float using Snacks
				open_command = "lua require('xcodebuild.util').open_float('Test Explorer', 'TestExplorer')",
			},
		},
		config = function(_, opts)
			-- Use your existing Snacks engine for the best possible floating UI
			local util = require("xcodebuild.util")
			util.open_float = function(path_or_name, filetype)
				if Snacks and Snacks.win then
					Snacks.win({
						file = (filetype == "xcodebuildlog") and path_or_name or nil,
						buf = (filetype == "TestExplorer") and vim.fn.bufnr(path_or_name) or nil,
						ft = filetype,
						width = 0.8,
						height = 0.8,
						border = "rounded",
						backdrop = 60,
						wo = { winhighlight = "Normal:NormalFloat,FloatBorder:SnacksNormal" },
					})
				end
			end

			require("xcodebuild").setup(opts)
		end,
		keys = {
			{ "<leader>xb", "<cmd>XcodebuildBuild<cr>", desc = "Xcode Build" },
			{ "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Xcode Build & Run" },
			{ "<leader>xt", "<cmd>XcodebuildTest<cr>", desc = "Xcode Test" },
			{ "<leader>xT", "<cmd>XcodebuildTestTarget<cr>", desc = "Xcode Test Target" },
			{ "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device" },
			{ "<leader>xp", "<cmd>XcodebuildSelectScheme<cr>", desc = "Select Scheme" },
			{ "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Logs" },
			{ "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle Coverage" },
		},
	},
}
