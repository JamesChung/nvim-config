return {
	"nvim-telescope/telescope.nvim",
	keys = {
		-- The util.project extra's <leader>fp only handles telescope/fzf-lua pickers;
		-- with snacks active it matches neither branch and silently does nothing.
		{
			"<leader>fp",
			function()
				require("snacks").picker.projects()
			end,
			desc = "Projects",
		},
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
