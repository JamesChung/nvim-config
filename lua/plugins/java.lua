return {
	{
		"mfussenegger/nvim-jdtls",
		opts = function(_, opts)
			-- Add JVM args for performance
			local jvm_args = {
				-- The max size should be modified to best fit your current machine's max.
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

			-- Get number of CPU cores with a cap
			local function get_core_count(max_cores)
				local ok, info = pcall(vim.uv.cpu_info)
				local cores = ok and info and #info or 2

				if cores > max_cores then
					return max_cores
				end

				return cores
			end

			-- Build correct bundle list (LazyVim's glob includes invalid JARs)
			local bundles = {}
			local mason_share = vim.fn.expand("$MASON/share")
			-- java-debug-adapter: all JARs are valid bundles
			vim.list_extend(bundles, vim.fn.glob(mason_share .. "/java-debug-adapter/*.jar", false, true))
			-- java-test: only the plugin JAR is a valid bundle (not runner, jacoco, junit deps)
			vim.list_extend(
				bundles,
				vim.fn.glob(mason_share .. "/java-test/com.microsoft.java.test.plugin*.jar", false, true)
			)

			-- Override bundles via jdtls config
			opts.jdtls = vim.tbl_deep_extend("force", opts.jdtls or {}, {
				init_options = {
					bundles = bundles,
				},
			})

			-- Extend JDTLS settings
			opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
				java = {
					-- Multiple JDK runtimes for project switching
					configuration = {
						updateBuildConfiguration = "automatic",
						runtimes = {
							{
								name = "AppleJDK-11",
								path = "/Library/Java/JavaVirtualMachines/applejdk-11.jdk/Contents/Home",
							},
							{
								name = "AppleJDK-17",
								path = "/Library/Java/JavaVirtualMachines/applejdk-17.jdk/Contents/Home",
							},
							{
								name = "AppleJDK-21",
								path = "/Library/Java/JavaVirtualMachines/applejdk-21.jdk/Contents/Home",
								default = true,
							},
							{
								name = "AppleJDK-25",
								path = "/Library/Java/JavaVirtualMachines/applejdk-25.jdk/Contents/Home",
							},
						},
					},

					-- mixes lightweight/full modes for quicker startup while retaining full features (available in JDT LS 1.31+;
					-- fallback to "Standard" if issues).
					server = { launchMode = "Hybrid" },

					-- Completion optimizations
					completion = {
						chain = { enabled = true },
						postfix = { enabled = true }, -- expr.if → if(expr), expr.var → var x = expr
						lazyResolveTextEdit = { enabled = true }, -- Faster completion response
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
						updateSnapshots = true,
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
					import = {
						gradle = {
							enabled = true,
							wrapper = { enabled = true },
							annotationProcessing = { enabled = true },
						},
						exclusions = {
							"**/node_modules/**",
							"**/.git/**",
							-- IDE configuration
							"**/.idea/**",
							"**/.settings/**",
						},
						generatesMetadataFilesAtProjectRoot = false,
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
						parameterNames = { enabled = "literals" }, -- or "all"
						variableTypes = { enabled = true },
						methodReturnTypes = { enabled = true },
					},

					-- Exclude common directories from file watching
					project = {
						resourceFilters = {
							"node_modules",
							".git",
							-- IDE configuration
							".idea",
							".settings",
						},
					},

					-- Auto-organize imports on save
					saveActions = {
						organizeImports = true,
					},

					-- Cleanup actions on save
					cleanup = {
						actions = {
							"addOverride",
							"addDeprecated",
							"lambdaExpression",
							"removeUnusedImports",
						},
					},

					-- Performance settings
					maxConcurrentBuilds = get_core_count(8),
					autobuild = { enabled = true },
				},
			})

			return opts
		end,
	},
}
