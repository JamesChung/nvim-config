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
				lsp_references = {
					-- Show window immediately with loading indicator instead of waiting for results
					show_delay = 0,
				},
			},
		},
	},
}
