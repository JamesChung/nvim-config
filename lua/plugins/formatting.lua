return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- Web development
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				["markdown.mdx"] = { "prettier" },
				graphql = { "prettier" },

				-- Compiled Languages
				java = { "palantir-java-format" },
				rust = { "rustfmt" },
				go = { "goimports", "gofmt" },

				-- Interpreted Languages
				python = { "isort", "black" },
				lua = { "stylua" },

				-- Other
				sh = { "shfmt" },
			},
			formatters = {
				["palantir-java-format"] = {
					-- NOTE: In order to get this binary you must build it from source at
					-- https://github.com/palantir/palantir-java-format
					-- run './gradlew :palantir-java-format-native:nativeCompile'
					-- copy that binary to your ~/.local/bin/palantir-java-format
					-- then this should work.
					command = "palantir-java-format",
					args = { "--palantir", "-" },
					stdin = true,
				},
			},
		},
	},
}
