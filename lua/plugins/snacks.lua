return {
	"folke/snacks.nvim",
	opts = {
		explorer = {
			enabled = false,
		},
		picker = {
			sources = {
				files = {
					hidden = false,
					ignored = false,
				},
				-- Show picker immediately with loading indicator instead of waiting for results
				lsp_references = { show_delay = 0 },
				lsp_definitions = { show_delay = 0 },
				lsp_type_definitions = { show_delay = 0 },
				lsp_implementations = { show_delay = 0 },
				lsp_declarations = { show_delay = 0 },
				lsp_symbols = { show_delay = 0 },
				lsp_incoming_calls = { show_delay = 0 },
				lsp_outgoing_calls = { show_delay = 0 },
			},
		},
	},
}
