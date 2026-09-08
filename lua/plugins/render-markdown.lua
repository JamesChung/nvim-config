return {
	"MeanderingProgrammer/render-markdown.nvim",
	opts = {
		code = {
			-- Disable background highlighting for all languages
			disable_background = true,
		},
		overrides = {
			buftype = {
				-- LSP hover floats are nofile buffers. The window is shrunk by one row for
				-- each concealed fence line, but the opening fence is drawn as a language
				-- badge rather than hidden, so that badge takes the only row and the text
				-- underneath is pushed out of view. Dropping the badge here lets the fence
				-- conceal properly, leaving the row for the content.
				nofile = {
					code = { language = false },
				},
			},
		},
	},
}
