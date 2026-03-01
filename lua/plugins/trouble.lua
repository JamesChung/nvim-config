return {
	"folke/trouble.nvim",
	opts = {},
	keys = {
		-- Disable standard LazyVim x mappings
		{ "<leader>xx", false },
		{ "<leader>xX", false },
		{ "<leader>xL", false },
		{ "<leader>xQ", false },
		{ "<leader>xt", false },
		{ "<leader>xT", false },

		-- Mnemonic Trouble Mappings (lowercase t)
		{
			"<leader>tp",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Project Diagnostics (Trouble)",
		},
		{
			"<leader>tb",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>ts",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>tl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>tq",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
		{
			"<leader>to",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location List (Trouble)",
		},
	},
}
