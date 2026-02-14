return {
	{
		"jay-babu/mason-nvim-dap.nvim",
		opts = {
			automatic_installation = { exclude = { "chrome" } },
		},
	},
	{
		"mfussenegger/nvim-dap",
		-- NOTE: Java DAP configuration handled by nvim-jdtls
		-- opts = function()
		-- 	local dap = require("dap")
		--
		-- 	-- Configure Java debugging
		-- 	dap.configurations.java = {
		-- 		{
		-- 			type = "java",
		-- 			request = "launch",
		-- 			name = "Debug (Launch) - Current File",
		-- 			mainClass = "${file}",
		-- 		},
		-- 		{
		-- 			type = "java",
		-- 			request = "attach",
		-- 			name = "Debug (Attach) - Remote",
		-- 			hostName = "127.0.0.1",
		-- 			port = 5005,
		-- 		},
		-- 	}
		-- end,
	},
	{
		"rcarriga/nvim-dap-ui",
		opts = {
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						{ id = "breakpoints", size = 0.25 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						{ id = "repl", size = 0.5 },
						{ id = "console", size = 0.5 },
					},
					size = 10,
					position = "bottom",
				},
			},
		},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)

			-- Auto-open DAP UI when debugging starts
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end

			-- Auto-close DAP UI when debugging ends
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
				vim.defer_fn(function()
					vim.cmd("Neotree close")
					vim.cmd("Neotree show")
				end, 100)
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
				vim.defer_fn(function()
					vim.cmd("Neotree close")
					vim.cmd("Neotree show")
				end, 100)
			end
		end,
	},
}
