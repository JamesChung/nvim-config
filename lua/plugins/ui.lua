return {
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000, -- Load early to replace default diagnostics
		opts = {
			preset = "modern", -- Style: modern, classic, minimal, powerline
			options = {
				-- Show diagnostics only on the current cursor line
				show_all_diags_on_cursorline = true,
				-- Enable showing source names (e.g., jdtls, lua_ls)
				show_source = { enabled = true },
				-- Automatically hide when opening standard diagnostic floats
				override_open_float = true,
			},
		},
	},
}
