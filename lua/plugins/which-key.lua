return {
	-- Configure which-key to label our custom prefixes
	{
		"folke/which-key.nvim",
		opts = function(_, opts)
			opts.spec = opts.spec or {}
			table.insert(opts.spec, {
				-- Troubleshooting and Testing (Overrides LazyVim defaults)
				{ "<leader>t", group = "trouble", icon = "⚠️ " },
				{ "<leader>T", group = "test", icon = "🧪 " },
				
				-- Java Specific Methods
				{ "<leader>j", group = "java", icon = "☕ " },
				
				-- Debugging (Merged with DAP defaults)
				{ "<leader>d", group = "debug", icon = "🐛 " },
				
				-- Code Actions / LSP
				{ "<leader>c", group = "code", icon = "⚙️ " },
				
				-- Workspace Management (Under Code)
				{ "<leader>cw", group = "workspace", icon = "📁 " },
				})
				end,
				},
				}
