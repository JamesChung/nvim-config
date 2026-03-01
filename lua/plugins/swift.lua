return {
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-treesitter/nvim-treesitter",
			"mfussenegger/nvim-dap",
		},
		lazy = false,
		ft = { "swift", "objc", "objcpp" },
		opts = {
			logs = {
				auto_open_on_success_tests = false,
				auto_open_on_failed_tests = true,
				auto_open_on_success_build = false,
				auto_open_on_failed_build = true,
				auto_focus = true,
				open_command = "lua require('xcodebuild.util').open_float('{path}', 'xcodebuildlog')",
			},
			test_explorer = {
				enabled = true,
				auto_open = true,
				open_command = "lua require('xcodebuild.util').open_float('Test Explorer', 'TestExplorer')",
			},
		},
		config = function(_, opts)
			local util = require("xcodebuild.util")

			-- Custom Floating Window Utility using Snacks
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

			-- Setup DAP Integration
			local status_ok, xcodebuild_dap = pcall(require, "xcodebuild.integrations.dap")
			if not status_ok then
				return
			end

			xcodebuild_dap.setup()

			local dap = require("dap")
			local project_config = require("xcodebuild.project.config")

			local function get_executable_path()
				if project_config.settings.appPath then
					return project_config.settings.appPath
				end

				-- Fallback for Swift Packages
				local product_name = project_config.settings.productName or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
				local expected_path = vim.fn.getcwd() .. "/.build/debug/" .. product_name

				if vim.fn.executable(expected_path) == 1 then
					return expected_path
				end

				return vim.fn.input("Path to executable: ", expected_path, "file")
			end

			local function run_swift_build()
				print("Building Swift Package...")
				local output = vim.fn.system("swift build")
				if vim.v.shell_error ~= 0 then
					vim.notify("Swift build failed:\n" .. output, vim.log.levels.ERROR)
					return false
				end
				print("Build successful!")
				return true
			end

			dap.configurations.swift = dap.configurations.swift or {}

			-- Inject custom configurations for xcodebuild
			local xcode_configs = {
				{
					name = "Build & Debug (xcodebuild)",
					build = true,
				},
				{
					name = "Debug Without Building (xcodebuild)",
					build = false,
				},
			}

			for i, cfg in ipairs(xcode_configs) do
				table.insert(dap.configurations.swift, i, {
					name = cfg.name,
					type = "codelldb",
					request = "launch",
					program = function()
						if project_config.settings.projectFile then
							-- Xcode Project Flow
							if cfg.build then
								xcodebuild_dap.build_and_debug()
							else
								xcodebuild_dap.debug_without_build()
							end
							return get_executable_path()
						else
							-- Swift Package Fallback
							if cfg.build and not run_swift_build() then
								return nil
							end
							return get_executable_path()
						end
					end,
				})
			end
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
