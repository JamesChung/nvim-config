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
			patterns = {
				".git",
				"_darcs",
				".hg",
				".bzr",
				".svn",
				"Makefile",
				"package.json",
				"pom.xml",
				"build.gradle",
			},
		},
	},
	{
		"folke/snacks.nvim",
		opts = function(_, opts)
			-- util.project injects a dashboard button bound to the same picker that
			-- no-ops under snacks; the built-in "p" entry already does the job.
			local keys = vim.tbl_get(opts, "dashboard", "preset", "keys")
			for i = #(keys or {}), 1, -1 do
				if keys[i].key == "P" and keys[i].desc == "Projects (util.project)" then
					table.remove(keys, i)
				end
			end
		end,
	},
}
