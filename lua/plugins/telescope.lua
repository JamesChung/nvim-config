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
		pickers = {
			find_files = {
				-- Use fd to respect gitignore by default
				find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
			},
		},
	},
}
