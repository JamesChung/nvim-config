-- Project roots are probed rather than hardcoded: this config is shared publicly.
-- A parent is dropped once a child of it is already kept, so ~/Repos cannot shadow
-- ~/Repos/Internal with container dirs that are not repositories themselves.
local function dev_roots()
	local candidates = {
		"~/Repos/Internal",
		"~/Repos/External",
		"~/Repos",
		"~/Projects",
		"~/src",
		"~/dev",
		"~/code",
		"~/.config",
	}

	local roots = {}
	for _, dir in ipairs(candidates) do
		if vim.fn.isdirectory(vim.fn.expand(dir)) == 1 then
			local shadowed = false
			for _, kept in ipairs(roots) do
				if kept:sub(1, #dir + 1) == dir .. "/" then
					shadowed = true
					break
				end
			end
			if not shadowed then
				roots[#roots + 1] = dir
			end
		end
	end
	return roots
end

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
		image = {
			enabled = true,
			-- Math rendering shells out to tectonic/pdflatex; no LaTeX toolchain here.
			math = { enabled = false },
		},
		picker = {
			sources = {
				files = {
					hidden = true,
					ignored = false,
				},
				projects = {
					dev = dev_roots(),
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
