return {
	"folke/snacks.nvim",
	-- Hand off file-find and grep to fff.nvim (see lua/plugins/fff.lua).
	-- LazyVim binds these on the snacks picker spec, so we disable them here.
	keys = {
		{ "<leader><space>", false },
		{ "<leader>/", false },
		-- util.project's <leader>fp only handles telescope/fzf-lua; with snacks
		-- active it matches neither branch and silently does nothing.
		{
			"<leader>fp",
			function()
				require("snacks").picker.projects()
			end,
			desc = "Projects",
		},
	},
	opts = {
		explorer = {
			enabled = false,
		},
		picker = {
			sources = {
				files = {
					hidden = true,
					ignored = false,
				},
				projects = {
					dev = { "~/Repos/Internal", "~/Projects", "~/.config" },
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
