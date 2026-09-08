return {
	{
		"jay-babu/mason-nvim-dap.nvim",
		opts = {
			automatic_installation = { exclude = { "chrome" } },
		},
	},
	{
		"mfussenegger/nvim-dap",
		keys = {
			-- Mnemonic Debug Mappings (lowercase d)
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Debug: Toggle Breakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: Breakpoint Condition",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Debug: Continue / Start",
			},
			{
				"<leader>da",
				function()
					require("dap").continue({
						before = function(config)
							local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
							local args_str = type(args) == "table" and table.concat(args, " ") or args
							config = vim.deepcopy(config)
							config.args = function()
								local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
								if config.type and config.type == "java" then
									return new_args
								end
								return require("dap.utils").splitstr(new_args)
							end
							return config
						end,
					})
				end,
				desc = "Debug: Run with Args",
			},
			{
				"<leader>dC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Debug: Run to Cursor",
			},
			{
				"<leader>dg",
				function()
					require("dap").goto_()
				end,
				desc = "Debug: Go to Line (No Execute)",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Debug: Step Into",
			},
			{
				"<leader>dj",
				function()
					require("dap").down()
				end,
				desc = "Debug: Down (Stack Frame)",
			},
			{
				"<leader>dk",
				function()
					require("dap").up()
				end,
				desc = "Debug: Up (Stack Frame)",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Debug: Run Last session",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Debug: Step Out",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_over()
				end,
				desc = "Debug: Step Over",
			},
			{
				"<leader>dp",
				function()
					require("dap").pause()
				end,
				desc = "Debug: Pause",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Debug: Toggle REPL",
			},
			{
				"<leader>ds",
				function()
					require("dap").session()
				end,
				desc = "Debug: Session Info",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Debug: Terminate",
			},
			{
				"<leader>dw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Debug: Widgets",
			},
		},
		config = function(plugin, opts)
			-- lazy.nvim replaces function fields instead of merging them, so this
			-- `config` must invoke the LazyVim `dap.core` extra's own config by hand
			-- or it would be discarded (dap signs, mason-nvim-dap setup, launch.json).
			local delegated = false
			for _, spec in ipairs(require("lazyvim.plugins.extras.dap.core")) do
				if spec[1] == "mfussenegger/nvim-dap" and type(spec.config) == "function" then
					spec.config(plugin, opts)
					delegated = true
				end
			end
			assert(delegated, "lua/plugins/dap.lua: lazyvim dap.core nvim-dap config not found")

			local dap = require("dap")

			-- Runs after every `opts` function, including the lazyvim java extra's,
			-- which ASSIGNS dap.configurations.java and would clobber an earlier insert.
			dap.configurations.java = dap.configurations.java or {}
			table.insert(dap.configurations.java, {
				type = "java",
				request = "launch",
				name = "Debug (Launch) - Current File",
				mainClass = "${file}",
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Debug: Toggle UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Debug: Eval",
				mode = { "n", "v" },
			},
		},
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

			-- Opening and closing the DAP UI re-lays out the window grid, which resizes the
			-- neo-tree sidebar. Record its width beforehand and put it back afterward.
			--
			-- Closing and reopening neo-tree around each transition would also work, but it
			-- errors when neo-tree has not been loaded, so adjust the width in place instead.
			-- The restore is scheduled rather than immediate so it runs once the layout
			-- change has settled.
			local explorer_width = nil

			local function explorer_win()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "neo-tree" then
						return win
					end
				end
			end

			local function remember_explorer()
				local win = explorer_win()
				explorer_width = win and vim.api.nvim_win_get_width(win) or nil
			end

			local function restore_explorer()
				if not explorer_width then
					return
				end
				local width = explorer_width
				vim.schedule(function()
					local win = explorer_win()
					if win and vim.api.nvim_win_is_valid(win) then
						pcall(vim.api.nvim_win_set_width, win, width)
					end
				end)
			end

			-- Auto-open DAP UI when debugging starts
			dap.listeners.after.event_initialized["dapui_config"] = function()
				remember_explorer()
				dapui.open()
				restore_explorer()
			end

			-- Auto-close DAP UI when debugging ends
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
				restore_explorer()
				explorer_width = nil
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
				restore_explorer()
				explorer_width = nil
			end
		end,
	},
}
