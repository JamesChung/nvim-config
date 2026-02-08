return {
	-- Configure conform.nvim to use palantir-java-format for Java files
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				java = { "palantir-java-format" },
			},
			formatters = {
				-- NOTE: In order to get this binary you must build it from source at
				-- https://github.com/palantir/palantir-java-format
				-- run './gradlew :palantir-java-format-native:nativeCompile'
				-- copy that binary to your ~/.local/bin/palantir-java-format
				-- then this should work.
				["palantir-java-format"] = {
					command = "palantir-java-format",
					args = { "--palantir", "-" },
					stdin = true,
				},
			},
		},
	},
	{
		"mfussenegger/nvim-jdtls",
		opts = function(_, opts)
			-- Fix lombok path (LazyVim uses $MASON/share/jdtls/ but mason installs to $MASON/packages/jdtls/)
			local lombok_jar = vim.fn.expand("$MASON/packages/jdtls/lombok.jar")
			for i, arg in ipairs(opts.cmd) do
				if arg:match("-javaagent:.*lombok%.jar") then
					opts.cmd[i] = string.format("--jvm-arg=-javaagent:%s", lombok_jar)
					break
				end
			end

			-- Add JVM args for performance
			local jvm_args = {
				"--jvm-arg=-Xmx8g",
				"--jvm-arg=-XX:+UseZGC",
				"--jvm-arg=-XX:+ZGenerational",
				"--jvm-arg=-XX:+UseStringDeduplication",
				"--jvm-arg=-XX:ReservedCodeCacheSize=1g",
				"--jvm-arg=-XX:SoftRefLRUPolicyMSPerMB=50",
				"--jvm-arg=-XX:-OmitStackTraceInFastThrow",
			}
			for _, arg in ipairs(jvm_args) do
				table.insert(opts.cmd, arg)
			end

			-- Disable main class scanning (performance killer on large monorepos)
			opts.dap_main = false

			-- Define all Java settings in one place
			local java_settings = {
				-- Disable built-in formatter (using palantir-java-format via conform.nvim)
				format = { enabled = false },

				-- Multiple JDK runtimes for project switching
				configuration = {
					updateBuildConfiguration = "automatic",
					runtimes = {
						{
							name = "JavaSE-11",
							path = "/Library/Java/JavaVirtualMachines/applejdk-11.jdk/Contents/Home",
						},
						{
							name = "JavaSE-17",
							path = "/Library/Java/JavaVirtualMachines/applejdk-17.jdk/Contents/Home",
						},
						{
							name = "JavaSE-21",
							path = "/Library/Java/JavaVirtualMachines/applejdk-21.jdk/Contents/Home",
							default = true,
						},
						{
							name = "JavaSE-25",
							path = "/Library/Java/JavaVirtualMachines/applejdk-25.jdk/Contents/Home",
						},
					},
				},

				-- Hybrid mode: fast startup, full features in background
				server = { launchMode = "Hybrid" },

				autobuild = { enabled = true },

				-- Completion optimizations
				completion = {
					chain = { enabled = true },
					postfix = { enabled = true },
					lazyResolveTextEdit = { enabled = true },
				},

				-- JDT Language Server features
				jdt = {
					ls = {
						lombokSupport = { enabled = true },
						protobufSupport = { enabled = true },
					},
				},

				-- Code lens (shows references/implementations above methods)
				referencesCodeLens = { enabled = false }, -- Expensive in monorepos
				implementationsCodeLens = { enabled = true },

				-- Download dependency sources for go-to-definition
				maven = {
					downloadSources = true,
					updateSnapshots = false,
				},

				-- Use fernflower for better decompiled source quality
				contentProvider = {
					preferred = "fernflower",
				},

				-- Better workspace symbol search
				symbols = {
					includeSourceMethodDeclarations = true,
				},

				-- Disable telemetry for corporate environments
				telemetry = {
					enabled = false,
				},

				-- Import organization
				sources = {
					organizeImports = {
						starThreshold = 999,
						staticStarThreshold = 999,
					},
				},

				-- Gradle settings
				-- NOTE: offline mode skips network dependency resolution for faster startup.
				-- If you add new dependencies, run `./gradlew build --refresh-dependencies` first.
				import = {
					gradle = {
						offline = { enabled = false },
					},
					exclusions = {
						"**/node_modules/**",
						"**/.git/**",
						"**/.idea/**",
					},
				},

				-- Signature help with javadoc descriptions
				signatureHelp = {
					enabled = true,
					description = { enabled = true },
				},

				-- Include decompiled sources in references
				references = {
					includeDecompiledSources = true,
				},

				inlayHints = {
					parameterNames = { enabled = "literals" },
					variableTypes = { enabled = true },
					methodReturnTypes = { enabled = true },
				},

				-- Auto-organize imports on save (disabled - using palantir-java-format)
				-- saveActions = {
				-- 	organizeImports = true,
				-- },

				-- Cleanup actions on save (disabled - using palantir-java-format)
				-- cleanup = {
				-- 	actions = {
				-- 		"addOverride",
				-- 		"addDeprecated",
				-- 		"lambdaExpression",
				-- 		"removeUnusedImports",
				-- 	},
				-- },
			}

			-- Set via opts.jdtls (gets merged into final config by LazyVim)
			-- Pass settings via init_options (like VS Code Java does) so they're available
			-- during initial Gradle import, before workspace/configuration is requested.
			opts.jdtls = opts.jdtls or {}
			opts.jdtls.settings = { java = java_settings }
			opts.jdtls.init_options = opts.jdtls.init_options or {}
			opts.jdtls.init_options.settings = { java = java_settings }

			return opts
		end,
	},
}
