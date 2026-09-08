return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			codelens = {
				enabled = true,
			},
			diagnostics = {
				-- MUST stay false: `virtual_text` alongside `virtual_lines` renders every
				-- diagnostic twice (once inline, once on the inserted virtual line).
				virtual_text = false,
				virtual_lines = {
					-- 0.13-dev caveat: `current_line` is expected to move from
					-- `CursorMoved` to `CursorHold`, at which point `'updatetime'` will
					-- govern how quickly the virtual line appears.
					current_line = true,
					-- Core's `format_virtual_lines` (runtime/lua/vim/diagnostic.lua:2165-2171)
					-- reads only `code` and `message` -- never `source`. The replaced
					-- tiny-inline-diagnostic.nvim had `show_source = { enabled = true }`, so
					-- this hook (honored at diagnostic.lua:2199) is what preserves source
					-- attribution.
					---@param diagnostic vim.Diagnostic
					---@return string
					format = function(diagnostic)
						local message = diagnostic.message or ""
						-- Sources are often reported with trailing punctuation
						-- (e.g. "Lua Diagnostics.").
						local source = diagnostic.source and (tostring(diagnostic.source):gsub("%.$", ""))
						local code = diagnostic.code and tostring(diagnostic.code)
						local label = (source and code) and (source .. ": " .. code) or source or code
						if label and label ~= "" then
							return string.format("%s: %s", label, message)
						end
						return message
					end,
				},
			},
			servers = {
				-- Disables LazyVim's buffer-local `nowait` `gr` -> lsp_references, which
				-- makes built-in `grn`/`grr`/`gri`/`gra`/`grt` UNREACHABLE on LSP attach.
				-- Must live under servers["*"].keys (opts_extend = "servers.*.keys"), NOT
				-- the spec's top-level `keys` -- there it is a silent no-op.
				["*"] = {
					keys = {
						{ "gr", false },
					},
				},
				bashls = {},
				cssls = {
					settings = {
						css = {
							lint = {
								unknownAtRules = "ignore",
							},
						},
					},
				},
				dotls = {},
				gradle_ls = {},
				lua_ls = {},
				sourcekit = {
					cmd = { "sourcekit-lsp" },
					capabilities = {
						workspace = {
							didChangeWatchedFiles = {
								dynamicRegistration = true,
							},
						},
					},
				},
				vimls = {},
			},
		},
	},
}
