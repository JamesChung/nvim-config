return {
	"nvim-neotest/neotest",
	keys = {
		-- Mnemonic Test Mappings (Capital T)
		{
			"<leader>Tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Test File (Neotest)",
		},
		{
			"<leader>Tr",
			function()
				require("neotest").run.run()
			end,
			desc = "Test Run Nearest (Neotest)",
		},
		{
			"<leader>Tl",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Test Last (Neotest)",
		},
		{
			"<leader>Ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Test Summary (Neotest)",
		},
		{
			"<leader>To",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Test Output (Neotest)",
		},
		{
			"<leader>TO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Test Output Panel (Neotest)",
		},
		{
			"<leader>Td",
			function()
				require("neotest").run.run({ strategy = "dap", suite = false })
			end,
			desc = "Test Debug Nearest (Neotest)",
		},
		{
			"<leader>Tw",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "Test Watch (Neotest)",
		},
		{
			"<leader>TS",
			function()
				require("neotest").run.stop()
			end,
			desc = "Test Stop (Neotest)",
		},
		{
			"<leader>Ta",
			function()
				require("neotest").run.attach()
			end,
			desc = "Test Attach (Neotest)",
		},

		-- Disable all default lowercase t mappings to keep prefix free
		{ "<leader>tt", false },
		{ "<leader>tT", false },
		{ "<leader>tr", false },
		{ "<leader>tl", false },
		{ "<leader>ts", false },
		{ "<leader>to", false },
		{ "<leader>tO", false },
		{ "<leader>tS", false },
		{ "<leader>tw", false },
		{ "<leader>td", false },
		{ "<leader>ta", false },
	},
}
