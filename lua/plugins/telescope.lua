return {
	"nvim-telescope/telescope.nvim",
	opts = {
		defaults = {
			-- Respect gitignore and exclude certain files
			file_ignore_patterns = {
				"%.git/",
				"node_modules/",
			},
		},
	},
}
