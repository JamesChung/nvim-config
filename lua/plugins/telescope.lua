return {
	"nvim-telescope/telescope.nvim",
	-- util.project binds <leader>fp here too, which makes the key a lazy-load
	-- trigger for telescope even though snacks.lua owns the real mapping.
	keys = {
		{ "<leader>fp", false },
	},
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
