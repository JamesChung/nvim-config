return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "rose-pine",
		},
	},
	{
		"ahmedkhalf/project.nvim",
		opts = {
			manual_mode = false,
			detection_methods = { "lsp", "pattern" },
			patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pom.xml", "build.gradle" },
		},
	},
}
